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
/// `Splitter.visibleThickness` and the `splitter` is
/// centered within it.
public struct SplitView<P: View, D: SplitDivider, S: View>: View {
    private let spacing: CGFloat
    /// Used to change the SplitLayout of a SplitView
    @ObservedObject private var layout: LayoutHolder
    /// Only affects the initial layout, but updated to `privateFraction` after dragging ends.
    /// In this way, SplitView users can save the `FractionHolder` state to reflect slider position for restarts.
    @ObservedObject private var fraction: FractionHolder
    /// Use to hide/show `secondary` independent of dragging. When value is `false`, will restore to `privateFraction`.
    @ObservedObject private var hide: SideHolder
    /// The `primary` View, left when `layout==.Horizontal`, top when `layout==.Vertical`.
    private let primary: P
    /// The `secondary` View, right when `layout==.Horizontal`, bottom when `layout==.Vertical`.
    private let secondary: S
    /// The `splitter` View that sits between `primary` and `secondary`.
    /// When set up using ViewModifiers, by default either `Splitter.horizontal` or `Splitter.vertical`.
    private let splitter: D
    /// Whether a `FractionHolder` was passed-in during `init`, to gate whether it is ever updated
    private let hasInitialFraction: Bool
    /// The key state that changes the split between `primary` and `secondary`
    @State private var privateFraction: CGFloat
    
    public var body: some View {
        GeometryReader { geometry in
            let horizontal = layout.isHorizontal
            let size = geometry.size
            let width = size.width
            let height = size.height
            let pLength = pLength(in: size)
            let sLength = sLength(in: size)
            let breadth = horizontal ? size.height : width
            let pWidth = max(0, horizontal ? min(width - spacing, pLength - spacing / 2) : breadth)
            let pHeight = max(0, horizontal ? breadth : min(height - spacing, pLength - spacing / 2))
            let sWidth = max(0, horizontal ? sLength - spacing / 2 : breadth)
            let sHeight = max(0, horizontal ? breadth : min(height - spacing, sLength - spacing / 2))
            let sOffset = horizontal ? CGSize(width: pWidth + spacing, height: 0) : CGSize(width: 0, height: pHeight + spacing)
            let center = horizontal ? CGPoint(x: sOffset.width - spacing / 2, y: height / 2) : CGPoint(x: width / 2, y: sOffset.height - spacing / 2)
            ZStack(alignment: .topLeading) {
                primary
                    .frame(width: pWidth, height: pHeight)
                secondary
                    .frame(width: sWidth, height: sHeight)
                    .offset(sOffset)
                splitter
                    .position(center)
                    .gesture(drag(in: size))
            }
            .clipped()  // Can cause problems in some List styles if not clipped
            .environmentObject(layout)
        }
    }
    
    public init(_ layout: LayoutHolder, spacing: CGFloat? = nil, fraction: FractionHolder? = nil, hide: SideHolder? = nil, @ViewBuilder primary: (()->P), @ViewBuilder splitter: (()->D), @ViewBuilder secondary: (()->S)) {
        self.layout = layout
        hasInitialFraction = fraction != nil                            // True updates fraction's value after drag
        self.fraction = fraction ?? FractionHolder()
        self.hide = hide ?? SideHolder()
        _privateFraction = State(initialValue: fraction?.value ?? 0.5)  // Local fraction updated during drag
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
        self.spacing = spacing ?? self.splitter.visibleThickness
    }
    
    public init(_ layout: SplitLayout, spacing: CGFloat? = nil, fraction: FractionHolder? = nil, hide: SideHolder? = nil, @ViewBuilder primary: (()->P), @ViewBuilder splitter: (()->D), @ViewBuilder secondary: (()->S)) {
        self.init(LayoutHolder(layout), spacing: spacing, fraction: fraction, hide: hide, primary: primary, splitter: splitter, secondary: secondary)
    }
    
    /// The Gesture recognized by the `splitter`
    ///
    /// The main function of dragging is to modify the `privateFraction`, which is always between 0 and 1.
    ///
    /// Whenever we drag, we also set `hide.value` to `nil`. This is because the `pLength` and
    /// `sLength` key off of `hide` to return the full width/height when its value is non-nil.
    ///
    /// When we are done dragging, we `updateFraction`, which does nothing unless there was
    /// a `FractionHolder` passed-in at `init` time as held in `hasInitialFraction`.
    private func drag(in size: CGSize) -> some Gesture {
        switch layout.value {
        case .Horizontal:
            return DragGesture()
                .onChanged { gesture in
                    hide.value = nil
                    privateFraction = min(1, max(0, gesture.location.x / size.width))
                }
                .onEnded { gesture in
                    updateFraction(to: privateFraction)
                }
        case .Vertical:
            return DragGesture()
                .onChanged { gesture in
                    hide.value = nil
                    privateFraction = min(1, max(0, gesture.location.y / size.height))
                }
                .onEnded { gesture in
                    updateFraction(to: privateFraction)
                }
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
        guard let side = hide.value else {
            return length * privateFraction
        }
        return side == .Secondary ? length : 0
    }
    
    /// The length of secondary in the layout direction, without regard to any inset for the Splitter
    private func sLength(in size: CGSize) -> CGFloat {
        let length = layout.isHorizontal ? size.width : size.height
        guard let side = hide.value else {
            return length - pLength(in: size)
        }
        return side == .Primary ? length : 0
    }
    
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView(.Horizontal,
            fraction: FractionHolder(0.75),
            primary: { Color.red },
            splitter: { Splitter.horizontal },
            secondary: {
                SplitView(.Vertical,
                    primary: { Color.blue },
                    splitter: { Splitter.vertical },
                    secondary: {
                        SplitView(.Vertical,
                            primary: { Color.green },
                            splitter: { Splitter.vertical },
                            secondary: { Color.yellow }
                        )
                    }
                )
            }
        )
        .frame(width: 400, height: 400)
        SplitView(.Horizontal,
            primary: { SplitView(.Vertical, primary: { Color.red }, splitter: { Splitter.vertical }, secondary: { Color.green }) },
            splitter: { Splitter.horizontal },
            secondary: { SplitView(.Horizontal, primary: { Color.blue }, splitter: { Splitter.horizontal }, secondary: { Color.yellow }) }
        )
        .frame(width: 400, height: 400)
    }
}

