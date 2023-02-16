//
//  SplitView.swift
//  SplitView
//
//  Created by Steven Harris on 8/9/21.
//

import SwiftUI

/// A View with a draggable `splitter` between `primary` and `secondary`.
///
/// Views are layed out either horizontally or vertically as defined by `layout`
/// and separated by `spacing`. The`spacing` is set to
/// `splitter.visibleThickness` and the `splitter` is
/// centered within it.
public struct SplitView<P: View, D: SplitDivider, S: View>: View {
    private let config: SplitConfig
    /// Used to change the SplitLayout of a SplitView
    @ObservedObject private var layout: LayoutHolder
    /// Only affects the initial layout, but updated to `privateFraction` after dragging ends.
    /// In this way, SplitView users can save the `FractionHolder` state to reflect slider position for restarts.
    @ObservedObject private var fraction: FractionHolder
    /// Use to hide/show `secondary` independent of dragging. When value is `false`, will restore to `privateFraction`.
    @ObservedObject private var hide: SideHolder
    /// The `primary` View, left when `layout==.horizontal`, top when `layout==.vertical`.
    private let primary: P
    /// The `secondary` View, right when `layout==.horizontal`, bottom when `layout==.vertical`.
    private let secondary: S
    /// The `splitter` View that sits between `primary` and `secondary`.
    /// When set up using ViewModifiers, by default either `Splitter.horizontal` or `Splitter.vertical`.
    private let splitter: D
    /// Whether a `FractionHolder` was passed-in during `init`, to gate whether it is ever updated
    private let hasInitialFraction: Bool
    /// The key state that changes the split between `primary` and `secondary`
    @State private var privateFraction: CGFloat
    /// The previous size, used to determine how to change `privateFraction` as size changes
    @State private var oldSize: CGSize = CGSize.zero
    /// Spacing is zero when the splitter isn't showing; i.e., when it is not draggable.
    private var spacing: CGFloat { isDraggable() ? splitter.visibleThickness : 0 }
    let minPFraction: CGFloat?
    let minSFraction: CGFloat?
    
    public var body: some View {
        GeometryReader { geometry in
            let horizontal = layout.isHorizontal
            let size = geometry.size
            let width = size.width
            let height = size.height
            let breadth = horizontal ? height : width
            let minPLength = breadth * (minPFraction ?? 0)
            let minSLength = breadth * (minSFraction ?? 0)
            let pLength = max(minPLength, pLength(in: size))
            let sLength = max(minSLength, sLength(in: size))
            let pWidth = max(minPLength, horizontal ? min(width - spacing, pLength - spacing / 2) : breadth)
            let pHeight = max(minPLength, horizontal ? breadth : min(height - spacing, pLength - spacing / 2))
            let sWidth = max(minSLength, horizontal ? sLength - spacing / 2 : breadth)
            let sHeight = max(minSLength, horizontal ? breadth : min(height - spacing, sLength - spacing / 2))
            let sOffset = horizontal ? CGSize(width: pWidth + spacing, height: 0) : CGSize(width: 0, height: pHeight + spacing)
            let center = horizontal ? CGPoint(x: pWidth + spacing / 2, y: height / 2) : CGPoint(x: width / 2, y: pHeight + spacing / 2)
            ZStack(alignment: .topLeading) {
                primary
                    .frame(width: pWidth, height: pHeight)
                secondary
                    .frame(width: sWidth, height: sHeight)
                    .offset(sOffset)
                // Only show the splitter if it is draggable. See isDraggable comments.
                if isDraggable() {
                    splitter
                        .position(center)
                        .gesture(drag(in: size))
                }
            }
            // Our size changes when the window size changes or the containing window's size changes.
            // We have to monitor this change when we have nested SplitViews or the nested ones don't properly adjust.
            .onChange(of: geometry.size) { size in
                setPrivateFraction(in: size)
            }
            // We need to get the last size set after we appear, so the initial sizing doesn't start from zero
            .onAppear {
                oldSize = geometry.size
            }
            .clipped()  // Can cause problems in some List styles if not clipped
            .environmentObject(layout)
        }
    }
    
    public init(_ layout: LayoutHolder, fraction: FractionHolder? = nil, hide: SideHolder? = nil, config: SplitConfig? = nil, @ViewBuilder primary: (()->P), @ViewBuilder splitter: (()->D), @ViewBuilder secondary: (()->S)) {
        self.layout = layout
        self.fraction = fraction ?? FractionHolder()
        self.hide = hide ?? SideHolder()
        self.config = config ?? SplitConfig()
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
        hasInitialFraction = fraction != nil                            // True updates fraction's value after drag
        _privateFraction = State(initialValue: fraction?.value ?? 0.5)  // Local fraction updated during drag
        minPFraction = self.config.minPFraction
        minSFraction = self.config.minSFraction
    }
    
    public init(_ layout: SplitLayout, spacing: CGFloat? = nil, fraction: FractionHolder? = nil, hide: SideHolder? = nil, config: SplitConfig? = nil, @ViewBuilder primary: (()->P), @ViewBuilder splitter: (()->D), @ViewBuilder secondary: (()->S)) {
        self.init(LayoutHolder(layout), fraction: fraction, hide: hide, config: config, primary: primary, splitter: splitter, secondary: secondary)
    }
    
    /// Set the privateFraction to maintain the size of the priority side when size changes.
    private func setPrivateFraction(in size: CGSize) {
        guard let side = config.priority else { return }
        let horizontal = layout.isHorizontal
        let newLength = horizontal ? size.width : size.height
        let oldLength = horizontal ? oldSize.width : oldSize.height
        let delta = newLength - oldLength
        if delta == 0 { return }
        let oldPLength = privateFraction * oldLength
        let newPLength = side.isPrimary ? oldPLength : max(0, oldPLength + delta)
        let newPrivateFraction = newPLength / newLength
        privateFraction = newPrivateFraction
        updateFraction(to: privateFraction)
        oldSize = size
    }
    
    /// The Gesture recognized by the `splitter`
    ///
    /// The main function of dragging is to modify the `privateFraction`, which is always between 0 and 1.
    /// The `privateFraction` accounts for the `visibleThickness` because for nested SplitViews
    /// with aligned layouts, the size for the nested view causes layout issues at the extremes of the containing view.
    ///
    /// Whenever we drag, we also set `hide.value` to `nil`. This is because the `pLength` and
    /// `sLength` key off of `hide` to return the full width/height when its value is non-nil.
    ///
    /// When we are done dragging, we `updateFraction`, which does nothing unless there was
    /// a `FractionHolder` passed-in at `init` time as held in `hasInitialFraction`.
    private func drag(in size: CGSize) -> some Gesture {
        let splitterInset = config.visibleThickness / 2
        switch layout.value {
        case .horizontal:
            return DragGesture()
                .onChanged { gesture in
                    let x = max(splitterInset, min(size.width - splitterInset, gesture.location.x))
                    hide.side = nil    // Otherwise will not be draggable if hidden
                    privateFraction = min(1 - (minSFraction ?? 0), max(minPFraction ?? 0, x / size.width))
                }
                .onEnded { gesture in
                    updateFraction(to: privateFraction)
                }
        case .vertical:
            return DragGesture()
                .onChanged { gesture in
                    let y = max(splitterInset, min(size.height - splitterInset, gesture.location.y))
                    hide.side = nil    // Otherwise will not be draggable if hidden
                    privateFraction = min(1 - (minSFraction ?? 0), max(minPFraction ?? 0, y / size.height))
                }
                .onEnded { gesture in
                    updateFraction(to: privateFraction)
                }
        }
    }
    
    /// The splitter is draggable if neither side is hidden or neither of the min fractions is specified.
    /// If a side is hidden, then it is only draggable if no minimum fraction is specified.
    ///
    /// When a minimum fraction is specified and we hide a side, then we want it to stay hidden and
    /// not be able to be dragged-out from its hiding place. Otherwise, it looks weird because you are
    /// dragging it out from a place it can never be dragged-to.
    ///
    /// Typically, an invisible splitter will always specify min fractions it has to stay within. We still want to
    /// be able to hide the views, though. If we do so, then we sure don't want the hidden view to be able
    /// to be dragged-out when there is no visible indication it is hidden.
    private func isDraggable() -> Bool {
        guard hide.side != nil || minPFraction != nil || minSFraction != nil else { return true }
        guard let side = hide.side else { return true }
        switch side {
        case .primary:
            return minPFraction == nil
        case .secondary:
            return minSFraction == nil
        }
    }
    
    /// Set the FractionHolder.value only if it was passed-in at initialization time
    private func updateFraction(to newFraction: CGFloat) {
        guard hasInitialFraction else { return }
        fraction.value = newFraction
    }
    
    /// The length of primary in the layout direction, without regard to any inset for the Splitter
    private func pLength(in size: CGSize) -> CGFloat {
        let length = layout.isHorizontal ? size.width : size.height
        guard let side = hide.side else {
            return length * privateFraction
        }
        return side.isSecondary ? length : 0
    }
    
    /// The length of secondary in the layout direction, without regard to any inset for the Splitter
    private func sLength(in size: CGSize) -> CGFloat {
        let length = layout.isHorizontal ? size.width : size.height
        guard let side = hide.side else {
            return length - pLength(in: size)
        }
        return side.isPrimary ? length : 0
    }
    
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView(.horizontal,
            fraction: FractionHolder(0.75),
            primary: { Color.red },
            splitter: { Splitter.horizontal },
            secondary: {
                SplitView(.vertical,
                    primary: { Color.blue },
                    splitter: { Splitter.vertical },
                    secondary: {
                        SplitView(.vertical,
                            primary: { Color.green },
                            splitter: { Splitter.vertical },
                            secondary: { Color.yellow }
                        )
                    }
                )
            }
        )
        .frame(width: 400, height: 400)
        SplitView(.horizontal,
            primary: { SplitView(.vertical, primary: { Color.red }, splitter: { Splitter.vertical }, secondary: { Color.green }) },
            splitter: { Splitter.horizontal },
            secondary: { SplitView(.horizontal, primary: { Color.blue }, splitter: { Splitter.horizontal }, secondary: { Color.yellow }) }
        )
        .frame(width: 400, height: 400)
    }
}

