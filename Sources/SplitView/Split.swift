//
//  SplitViews.swift
//  SplitView
//
//  Created by Steven Harris on 8/9/21.
//

import SwiftUI

/// A View with a draggable `splitter` between `primary` and `secondary`.
///
/// Views are layed out either horizontally or vertically as defined by `layout`
/// and separated by `spacing`. The`spacing` is set to
/// `styling.visibleThickness` and the `splitter` is
/// centered within it.
///
/// The same Split view is used regardless of `layout`, since the math is all the same but applied
/// to width or height depending on whether `layout.isHorizontal` or not.
public struct Split<P: View, D: View, S: View>: View {
    
    /// The style for the `splitter`, which also holds the `visibleThickness`
    private let styling: SplitStyling
    /// The constraints within which the splitter can travel and which side if any has priority
    private let constraints: SplitConstraints
    /// Used to change the SplitLayout of a Split
    @ObservedObject private var layout: LayoutHolder
    /// Only affects the initial layout, but updated to `privateFraction` after dragging ends.
    /// In this way, Split users can save the `FractionHolder` state to reflect slider position for restarts.
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
    /// The key state that changes the split between `primary` and `secondary`
    @State private var privateFraction: CGFloat
    /// The previous size, used to determine how to change `privateFraction` as size changes
    @State private var oldSize: CGSize?
    /// The previous position as we drag the `splitter`
    @State private var previousPosition: CGFloat?
    /// Spacing is zero when the splitter isn't showing; i.e., when it is not draggable.
    private var spacing: CGFloat { isDraggable() ? styling.visibleThickness : 0 }
    private let halfSpacing: CGFloat
    private let minPFraction: CGFloat?
    private let minSFraction: CGFloat?
    
    public var body: some View {
        GeometryReader { geometry in
            let horizontal = layout.isHorizontal
            let size = geometry.size
            let width = size.width
            let height = size.height
            let length = horizontal ? width : height
            let breadth = horizontal ? height : width
            let minPLength = length * (minPFraction ?? 0)
            let minSLength = length * (minSFraction ?? 0)
            let pLength = max(minPLength, pLength(in: size))
            let sLength = max(minSLength, sLength(in: size))
            let pWidth = horizontal ? max(minPLength, min(width - spacing, pLength - spacing / 2)) : breadth
            let pHeight = horizontal ? breadth : max(minPLength, min(height - spacing, pLength - spacing / 2))
            let sWidth = horizontal ? max(minSLength, min(width - pLength, sLength - spacing / 2)) : breadth
            let sHeight = horizontal ? breadth : max(minSLength, min(height - pLength, sLength - spacing / 2))
            let sOffset = horizontal ? CGSize(width: pWidth + spacing, height: 0) : CGSize(width: 0, height: pHeight + spacing)
            let dCenter = horizontal ? CGPoint(x: pWidth + spacing / 2, y: height / 2) : CGPoint(x: width / 2, y: pHeight + spacing / 2)
            ZStack(alignment: .topLeading) {
                primary
                    .frame(width: pWidth, height: pHeight)
                secondary
                    .frame(width: sWidth, height: sHeight)
                    .offset(sOffset)
                // Only show the splitter if it is draggable. See isDraggable comments.
                if isDraggable() {
                    splitter
                        .position(dCenter)
                        .gesture(drag(in: size))
                }
            }
            // Our size changes when the window size changes or the containing window's size changes.
            // Note our size doesn't change when dragging the splitter, but when we have nested split
            // views, dragging our splitter can cause the size of another split view to change.
            // Use task instead of both onChange and onAppear because task will only executed when
            // geometry.size changes. Sometimes onAppear starts with CGSize.zero, which causes issues.
            .task(id: geometry.size) {
                setPrivateFraction(in: geometry.size)
            }
            .clipped()  // Can cause problems in some List styles if not clipped
            .environmentObject(layout)
            .environmentObject(styling)
        }
    }

    /// Public init only allows `primary` and `secondary`, with `splitter` defaulting to Splitter.
    ///
    /// The `layout`, `fraction`,  `hide` ,  `styling`, `constraints`, and any custom `splitter` must be specified using the modifiers if they are not defaults
    public init(@ViewBuilder primary: @escaping ()->P, @ViewBuilder secondary: @escaping ()->S) where D == Splitter {
        let layout = LayoutHolder()
        let fraction = FractionHolder()
        let hide = SideHolder()
        let styling = SplitStyling()
        let constraints = SplitConstraints()
        self.init(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary() }, splitter: { D() }, secondary: { secondary() })
    }
    
    /// Private init requires all values for Split state to be specified and is used by the modifiers.
    private init(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, styling: SplitStyling, constraints: SplitConstraints, @ViewBuilder primary: @escaping ()->P, @ViewBuilder splitter: @escaping ()->D, @ViewBuilder secondary: @escaping ()->S) {
        self.layout = layout
        self.fraction = fraction
        self.hide = hide
        self.styling = styling
        self.constraints = constraints
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
        _privateFraction = State(initialValue: fraction.value)  // Local fraction updated during drag
        halfSpacing = styling.visibleThickness / 2
        minPFraction = constraints.minPFraction
        minSFraction = constraints.minSFraction
    }

    /// Set the privateFraction to maintain the size of the priority side when size changes, as called from task(id:) modifier.
    private func setPrivateFraction(in size: CGSize) {
        guard let side = constraints.priority else { return }
        guard let oldSize else {
            // We need to know the oldSize to be able to adjust privateFraction in a way
            // that maintains a fixed width/height for the priority side.
            oldSize = size
            return
        }
        let horizontal = layout.isHorizontal
        let oldLength = horizontal ? oldSize.width : oldSize.height
        let newLength = horizontal ? size.width : size.height
        let delta = newLength - oldLength
        self.oldSize = size     // Retain even if delta might be zero because layout might change
        if delta == 0 { return }
        let oldPLength = privateFraction * oldLength
        // If holding the primary side constant, the pLength doesn't change
        let newPLength = side.isPrimary ? oldPLength : oldPLength + delta
        let newFraction = newPLength / newLength
        // Always keep the privateFraction within bounds of minimums if specified
        privateFraction = min(1 - (minSFraction ?? 0), max((minPFraction ?? 0), newFraction))
        fraction.value = privateFraction
    }
    
    /// The Gesture recognized by the `splitter`.
    ///
    /// The main function of dragging is to modify the `privateFraction`, which is always between 0 and 1 but
    /// doesn't exceed the bounds of the `visibleThickness` (or `minPFraction`/`minSFraction` if specified).
    /// In other words, while `privateFraction` can be 0 or 1 when `visibleThickess` is zero, it's almost always
    /// between those values because the `splitter` is visible and/or the minimum fractions were specified.
    ///
    /// Whenever we drag, we also set `hide.value` to `nil`. This is because the `pLength` and
    /// `sLength` key off of `hide` to return the full width/height when its value is non-nil.
    ///
    /// When we are done dragging, we the value of `fraction`, which does nothing unless someone
    /// is holding onto it. If, for example, a FractionHolder was passed-in using the `fraction()` modifier
    /// here or in HSplit/VSplit, then we keep its value in sync so that next time the Split view is opened, it
    /// maintains its state.
    private func drag(in size: CGSize) -> some Gesture {
        return DragGesture()
            .onChanged { gesture in
                unhide(in: size)    // Unhide if the splitter is hidden, but resetting privateFraction first
                privateFraction = fraction(for: gesture, in: size)
                previousPosition = layout.isHorizontal ? gesture.location.x : gesture.location.y
            }
            .onEnded { gesture in
                previousPosition = nil
                fraction.value = privateFraction
            }
    }
    
    /// Return a new value for privateFraction based on the DragGesture.
    ///
    /// The returned value is always within the allowed bounds within size as constrained by the `visibleThickness`
    /// of the `splitter` and the `minSFraction` and `minPFraction` (if specified).
    ///
    /// We use a delta based on `previousPosition` so the `splitter` follows the location where drag begins, not
    /// the center of the splitter. This way the drag is smooth from the beginning, rather than jumping the splitter location to
    /// the starting drag point.
    func fraction(for gesture: DragGesture.Value, in size: CGSize) -> CGFloat {
        let horizontal = layout.isHorizontal
        let length = horizontal ? size.width : size.height                                              // Size in direction of dragging
        let splitterLocation = length * privateFraction                                                 // Splitter position prior to drag
        let gestureLocation = horizontal ? gesture.location.x : gesture.location.y                      // Gesture location in direction of dragging
        let gestureTranslation = horizontal ? gesture.translation.width : gesture.translation.height    // Gesture movement since beginning of drag
        let delta = previousPosition == nil ? gestureTranslation : gestureLocation - previousPosition!  // Amount moved since last change
        let constrainedLocation = max(halfSpacing, min(length - halfSpacing, splitterLocation + delta)) // New location kept in proper bounds
        let newFraction = constrainedLocation / length                                                  // New privateFraction without regard to minimums
        return min(1 - (minSFraction ?? 0), max((minPFraction ?? 0), newFraction))                      // Constrained privateFraction
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
    
    /// Unhide before dragging if a side is hidden.
    ///
    /// When we set hide.size to nil, the body is recomputed based on privateFraction. However,
    /// privateFraction is set to what it was before hiding (so it can be restored properly). Here we
    /// reset privateFraction to the "hidden" position so that drag behaves smoothly from that
    /// position.
    private func unhide(in size: CGSize) {
        if hide.side != nil {
            let length = layout.isHorizontal ? size.width : size.height
            let pLength = pLength(in: size)
            privateFraction = pLength/length
            hide.side = nil
        }
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
    
    //MARK: Modifiers
    
    /// Return a new Split with the `splitter` set to a new type.
    ///
    /// If the splitter is a SplitDivider, get its `visibleThickness` and set that in `styling` before returning.
    public func splitter<T>(@ViewBuilder _ splitter: @escaping ()->T) -> Split<P, T, S> where T: View {
        let newSplitter = splitter()
        if let splitDivider = newSplitter as? (any SplitDivider) {
            styling.visibleThickness = splitDivider.visibleThickness
        }
        return Split<P, T, S>(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: splitter, secondary: { secondary })
    }
    
    public func constraints(minPFraction: CGFloat? = nil, minSFraction: CGFloat? = nil, priority: SplitSide? = nil) -> Split {
        let constraints = SplitConstraints(minPFraction: minPFraction, minSFraction: minSFraction, priority: priority)
        return Split(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    public func constraints(_ constraints: SplitConstraints) -> Split {
        self.constraints(minPFraction: constraints.minPFraction, minSFraction: constraints.minSFraction, priority: constraints.priority)
    }
    
    public func styling(color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) -> Split {
        let styling = SplitStyling(color: color, inset: inset, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness)
        return Split(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    public func styling(_ styling: SplitStyling) -> Split {
        self.styling(color: styling.color, inset: styling.inset, visibleThickness: styling.visibleThickness, invisibleThickness: styling.invisibleThickness)
    }
    
    /// Return a new instance of Split with `layout` set to this LayoutHolder
    public func layout(_ layout: LayoutHolder) -> Split {
        Split(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of Split with `layout` set to a LayoutHolder holding onto this SplitLayout
    public func layout(_ layout: SplitLayout) -> Split {
        self.layout(LayoutHolder(layout))
    }
    
    /// Return a new instance of Split with `fraction` set to this FractionHolder
    public func fraction(_ fraction: FractionHolder) -> Split {
        Split(layout, fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of Split with `fraction` set to a FractionHolder holding onto this CGFloat
    public func fraction(_ fraction: CGFloat) -> Split {
        self.fraction(FractionHolder(fraction))
    }
    
    /// Return a new instance of Split with `hide` set to this SideHolder
    public func hide(_ side: SideHolder) -> Split {
        Split(layout, fraction: fraction, hide: side, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of Split with `hide` set to a SideHolder holding onto this SplitSide
    public func hide(_ side: SplitSide) -> Split {
        self.hide(SideHolder(side))
    }
    
}

//struct Split_Previews: PreviewProvider {
//    static var previews: some View {
//        Split(.horizontal,
//            fraction: FractionHolder(0.75),
//            primary: { Color.red },
//            splitter: { Splitter.horizontal },
//            secondary: {
//                Split(.vertical,
//                    primary: { Color.blue },
//                    splitter: { Splitter.vertical },
//                    secondary: {
//                        Split(.vertical,
//                            primary: { Color.green },
//                            splitter: { Splitter.vertical },
//                            secondary: { Color.yellow }
//                        )
//                    }
//                )
//            }
//        )
//        .frame(width: 400, height: 400)
//        Split(.horizontal,
//            primary: { Split(.vertical, primary: { Color.red }, splitter: { Splitter.vertical }, secondary: { Color.green }) },
//            splitter: { Splitter.horizontal },
//            secondary: { Split(.horizontal, primary: { Color.blue }, splitter: { Splitter.horizontal }, secondary: { Color.yellow }) }
//        )
//        .frame(width: 400, height: 400)
//    }
//}
