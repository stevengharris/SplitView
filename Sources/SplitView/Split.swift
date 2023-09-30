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
    /// Whether primary view should be resized or offsett keeping its original frame
    public let isResizing: Bool
    /// The `primary` View, left when `layout==.horizontal`, top when `layout==.vertical`.
    private let primary: P
    /// The `secondary` View, right when `layout==.horizontal`, bottom when `layout==.vertical`.
    private let secondary: S
    /// The `splitter` View that sits between `primary` and `secondary`.
    /// When set up using ViewModifiers, by default either `Splitter.horizontal` or `Splitter.vertical`.
    private let splitter: D
    /// The style for the `splitter`, which also holds the `visibleThickness`
    private let styling: SplitStyling
    /// The constraints within which the splitter can travel and which side if any has priority
    private let constraints: SplitConstraints
    /// Function to execute with `constrainedFraction` as argument during drag
    private let onDrag: ((CGFloat) -> Void)?
    /// The minimum fraction of full width/height that `primary` can occupy
    private let minPFraction: CGFloat?
    /// The minimum fraction of full width/height that `secondary` can occupy
    private let minSFraction: CGFloat?
    /// Whether `primary` can be hidden by dragging beyond half of `minPFraction`
    private let dragToHideP: Bool
    /// Whether `secondary` can be hidden by dragging beyond half of `minSFraction`
    private let dragToHideS: Bool
    /// Used to change the SplitLayout of a Split
    @ObservedObject private var layout: LayoutHolder
    /// Only affects the initial layout, but updated to `constrainedFraction` after dragging ends.
    /// In this way, Split users can save the `FractionHolder` state to reflect slider position for restarts.
    @ObservedObject private var fraction: FractionHolder
    /// Use to hide/show `secondary` independent of dragging. When value is `false`, will restore to `constrainedFraction`.
    @ObservedObject private var hide: SideHolder
    /// Fraction that tracks the `splitter` position across full width/height, where minPFraction <= constrainedFraction <= (1-minSFraction)
    @State private var constrainedFraction: CGFloat
    /// Fraction that tracks the cursor across full width/height during drag, where 0  <= fullFraction <= 1
    @State private var fullFraction: CGFloat
    /// The previous size, used to determine how to change `constrainedFraction` as size changes
    @State private var oldSize: CGSize?
    /// The previous position as we drag the `splitter`
    @State private var previousPosition: CGFloat?

    public var body: some View {
        GeometryReader { geometry in
            let horizontal = layout.isHorizontal
            let size = geometry.size
            let width = size.width
            let height = size.height

            let length = horizontal ? width : height
            let breadth = horizontal ? height : width

            let hidePrimary = sideToHide() == .primary || hide.side == .primary
            let hideSecondary = sideToHide() == .secondary || hide.side == .secondary

            let minPLength = length * ((hidePrimary ? 0 : minPFraction) ?? 0)
            let minSLength = length * ((hideSecondary ? 0 : minSFraction) ?? 0)

            let pLength = max(minPLength, pLength(in: size))
            let sLength = max(minSLength, sLength(in: size))

            let spacing = spacing()

            let pWidth = horizontal ? max(minPLength, min(width - spacing, pLength - spacing / 2)) : breadth
            let pHeight = horizontal ? breadth : max(minPLength, min(height - spacing, pLength - spacing / 2))

            let sWidth = horizontal ? max(minSLength, min(width - pLength, sLength - spacing / 2)) : breadth
            let sHeight = horizontal ? breadth : max(minSLength, min(height - pLength, sLength - spacing / 2))

            let sOffset = horizontal ? CGSize(width: pWidth + spacing, height: 0) : CGSize(width: 0, height: pHeight + spacing)
            let pOffset = horizontal ? CGSize(width: -(width - sOffset.width) - spacing, height: 0) : CGSize(width: 0, height: -(height - sOffset.height) - spacing)

            let dCenter = horizontal ? CGPoint(x: pWidth + spacing / 2, y: height / 2) : CGPoint(x: width / 2, y: pHeight + spacing / 2)

            ZStack(alignment: .topLeading) {
                if !hidePrimary {
                    if isResizing {
                        primary
                            .frame(width: pWidth, height: pHeight)
                    } else {
                        primary
                            .frame(width: pWidth)
                            .offset(pOffset)
                    }
                }
                if !hideSecondary {
                    secondary
                        .frame(width: sWidth, height: sHeight)
                        .offset(sOffset)
                }
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
                setConstrainedFraction(in: geometry.size)
            }
            .clipped() // Can cause problems in some List styles if not clipped
            .environmentObject(layout)
            .environmentObject(styling)
        }
    }

    /// Public init only allows `primary` and `secondary`, with `splitter` defaulting to Splitter.
    ///
    /// The `layout`, `fraction`,  `hide` ,  `styling`, `constraints`, and any custom `splitter` must be specified using the modifiers if they are not defaults
    public init(
        isResizing: Bool = true,
        @ViewBuilder primary: @escaping () -> P,
        @ViewBuilder secondary: @escaping () -> S
    ) where D == Splitter {
        let layout = LayoutHolder()
        let fraction = FractionHolder()
        let hide = SideHolder()
        let styling = SplitStyling()
        let constraints = SplitConstraints()
        self.init(layout,
                  isResizing: isResizing,
                  fraction: fraction,
                  hide: hide,
                  styling: styling,
                  constraints: constraints,
                  onDrag: nil,
                  primary: { primary() },
                  splitter: { D() },
                  secondary: { secondary() })
    }

    /// Private init requires all values for Split state to be specified and is used by the modifiers.
    private init(
        _ layout: LayoutHolder,
        isResizing: Bool,
        fraction: FractionHolder,
        hide: SideHolder,
        styling: SplitStyling,
        constraints: SplitConstraints,
        onDrag: ((CGFloat) -> Void)?,
        @ViewBuilder primary: @escaping () -> P,
        @ViewBuilder splitter: @escaping () -> D,
        @ViewBuilder secondary: @escaping () -> S
    ) {
        self.layout = layout
        self.isResizing = isResizing
        self.fraction = fraction
        self.hide = hide
        self.styling = styling
        self.constraints = constraints
        self.onDrag = onDrag
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
        _constrainedFraction = State(initialValue: fraction.value) // Local fraction updated during drag
        _fullFraction = State(initialValue: fraction.value) // Local fraction updated during drag
        // Constants we use a lot and want to simplify access and avoid recomputing
        self.minPFraction = constraints.minPFraction
        self.minSFraction = constraints.minSFraction
        self.dragToHideP = constraints.minPFraction != nil && constraints.dragToHideP
        self.dragToHideS = constraints.minSFraction != nil && constraints.dragToHideS
        // If we are using drag-to-hide, then we force styling.hideSplitter to true
        if dragToHideP || dragToHideS { styling.hideSplitter = true }
    }

    /// Return the spacing between `primary` and `secondary`, which is occupied by the splitter's `visibleThickness`.
    ///
    /// If we are previewing the hide (i.e., drag-to-hide) or we are using the `hideSplitter` styling and a side is hidden,
    /// then return 0, because the splitter is not visible.
    private func spacing() -> CGFloat {
        if styling.previewHide {
            return 0
        } else if hide.side != nil && styling.hideSplitter {
            return 0
        } else {
            return styling.visibleThickness
        }
    }

    /// Set the constrainedFraction to maintain the size of the priority side when size changes, as called from task(id:) modifier.
    private func setConstrainedFraction(in size: CGSize) {
        guard let side = constraints.priority else { return }
        guard let oldSize else {
            // We need to know the oldSize to be able to adjust constrainedFraction in a way
            // that maintains a fixed width/height for the priority side.
            oldSize = size
            return
        }
        let horizontal = layout.isHorizontal
        let oldLength = horizontal ? oldSize.width : oldSize.height
        let newLength = horizontal ? size.width : size.height
        let delta = newLength - oldLength
        self.oldSize = size // Retain even if delta might be zero because layout might change
        if delta == 0 { return }
        let oldPLength = constrainedFraction * oldLength
        // If holding the primary side constant, the pLength doesn't change
        let newPLength = side.isPrimary ? oldPLength : oldPLength + delta
        let newFraction = newPLength / newLength
        // Always keep the constrainedFraction within bounds of minimums if specified
        constrainedFraction = min(1 - (minSFraction ?? 0), max(minPFraction ?? 0, newFraction))
        fraction.value = constrainedFraction
    }

    /// The Gesture recognized by the `splitter`.
    ///
    /// The main function of dragging is to modify the `constrainedFraction` and to track `fullFraction`.
    ///
    /// Whenever we drag, we also set `hide.value` to `nil`. This is because the `pLength` and
    /// `sLength` key off of `hide` to return the full width/height when its value is non-nil.
    ///
    /// When we are done dragging, we the value of `fraction`, which does nothing unless someone
    /// is holding onto it. If, for example, a FractionHolder was passed-in using the `fraction()` modifier
    /// here or in HSplit/VSplit, then we keep its value in sync so that next time the Split view is opened, it
    /// maintains its state.
    ///
    /// If `dragToHideP`/`dragToHideS` is set in constraints, automatically hide the side when done dragging if
    /// `sideToHide` returns a side that should be hidden. The `splitter` is always hidden in this case -
    /// iow, `styling.hideSplitter` is forced to true in the `init` method.
    ///
    /// Note that during drag, we "preview" that a side will be hidden. While previewing, the `splitter`
    /// color is `.clear`, and the size of `primary` and `secondary` are adjusted. This is different
    /// than when a side is actually hidden (i.e., when `hide.side` is non-nil). In the latter case, the
    /// `splitter` is not part of `body` - it doesn't exist to be dragged.
    private func drag(in size: CGSize) -> some Gesture {
        return DragGesture()
            .onChanged { gesture in
                unhide(in: size) // Unhide if the splitter is hidden, but resetting constrainedFraction first
                let fraction = fraction(for: gesture, in: size)
                constrainedFraction = fraction.constrained
                fullFraction = fraction.full
                styling.previewHide = !isDraggable() || sideToHide() != nil
                onDrag?(constrainedFraction)
                previousPosition = layout.isHorizontal ? constrainedFraction * size.width : constrainedFraction * size.height
            }
            .onEnded { gesture in
                previousPosition = nil
                styling.previewHide = false // We are never previewing the hidden state when drag ends
                hide.side = sideToHide()
                // The fullFraction is used to determine the sideToHide, so we need to reset when done dragging,
                // but *after* setting the hide.side.
                fullFraction = constrainedFraction
                fraction.value = constrainedFraction
            }
    }

    /// Return the side to hide for previewing in the drag-to-hide operation.
    ///
    /// Note a side is not necessarily hidden when `sideToHide` is called.
    ///
    /// Use a rounded-to-3-decimal-places constrainedFraction because... floating point.
    private func sideToHide() -> SplitSide? {
        guard dragToHideP || dragToHideS else { return nil }
        if dragToHideP && (round(fullFraction * 1000) / 1000.0) <= (minPFraction! / 2) {
            return .primary
        } else if dragToHideS && (round((1 - fullFraction) * 1000) / 1000.0) <= (minSFraction! / 2) {
            return .secondary
        } else {
            return nil
        }
    }

    /// Return a new value for `constrained` and `full` fractions based on the DragGesture.
    ///
    /// The `constrained` value is always between `minSFraction` and `minPFraction` (if specified).
    /// The `full` value is always between 0 and 1.
    ///
    /// We use a delta based on `previousPosition` so the `splitter` follows the location where drag begins, not
    /// the center of the splitter. This way the drag is smooth from the beginning, rather than jumping the splitter location to
    /// the starting drag point.
    func fraction(
        for gesture: DragGesture.Value,
        in size: CGSize
    ) -> (constrained: CGFloat, full: CGFloat) {
        let horizontal = layout.isHorizontal
        let length = horizontal ? size.width : size.height // Size in direction of dragging
        let splitterLocation = length * constrainedFraction // Splitter position prior to drag
        let gestureLocation = horizontal ? gesture.location.x : gesture.location.y // Gesture location in direction of dragging
        let gestureTranslation = horizontal ? gesture.translation.width : gesture.translation.height // Gesture movement since beginning of drag
        let delta = previousPosition == nil ? gestureTranslation : gestureLocation - previousPosition! // Amount moved since last change
        let constrainedLocation = max(0, min(length, splitterLocation + delta)) // New location kept in proper bounds
        let fullFraction = constrainedLocation / length // Fraction of full size without regard to constraints
        let constrainedFraction = min(1 - (minSFraction ?? 0), max(minPFraction ?? 0, fullFraction)) // Fraction of full size kept within constraints
        return (constrained: constrainedFraction, full: fullFraction)
    }

    /// Return whether the splitter is draggable.
    ///
    /// The splitter becomes non-draggable if `styling.hideSplitter` is `true`
    /// and either side is hidden. It will also be non-draggable when the `primary` side is
    /// hidden and `minPFraction` is specified, or when the `secondary` side is hidden
    /// and `minSFraction` is specified. When the splitter is non-draggable, it is not part of
    /// the `body` of Split. It is not just hidden -- it doesn't even exist to respond to drag events.
    ///
    /// When using drag-to-split by specifying `constraints.dragToHideP` and/or
    /// `constraints.dragToHideS`, `styling.hideSplitter` is  forced to `true`.
    /// Why? It's easier to see than explain. Try removing the last line in the private `init` and
    /// see for yourself.
    ///
    /// **Important**: You must provide a means to unhide the side (e.g., a hide/show
    /// button) if your splitter can become non-draggable.
    ///
    /// On a related note, when you use an invisible splitter, you will typically specify min
    /// fractions it has to stay within. If you don't, then it can be dragged to the edge, and
    /// your user will have no visual indication that the other side can be re-exposed by dragging
    /// the invisible splitter out again.
    private func isDraggable() -> Bool {
        if hide.side == nil { return true }
        if styling.hideSplitter {
            return false
        } else {
            if minPFraction == nil && minSFraction == nil {
                return true
            } else if hide.side!.isPrimary {
                return minPFraction == nil
            } else {
                return minSFraction == nil
            }
        }
    }

    /// Unhide before dragging if a side is hidden.
    ///
    /// When we set `hide.size` to nil, the `body` is recomputed based on `constrainedFraction`.
    /// However, `constrainedFraction` is set to what it was before hiding (so it can be restored properly).
    /// Here we reset `constrainedFraction` to the "hidden" position so that drag behaves smoothly from
    /// that position.
    private func unhide(in size: CGSize) {
        if hide.side != nil {
            let length = layout.isHorizontal ? size.width : size.height
            let pLength = pLength(in: size)
            constrainedFraction = pLength / length
            hide.side = nil
        }
    }

    /// The length of `primary` in the `layout` direction, without regard to any inset for the Splitter
    private func pLength(in size: CGSize) -> CGFloat {
        let length = layout.isHorizontal ? size.width : size.height
        if let side = hide.side {
            return side.isSecondary ? length : 0
        } else {
            if let sideToHide = sideToHide() {
                return sideToHide.isSecondary ? length : 0
            } else {
                return length * constrainedFraction
            }
        }
    }

    /// The length of `secondary` in the `layout` direction, without regard to any inset for the Splitter
    private func sLength(in size: CGSize) -> CGFloat {
        let length = layout.isHorizontal ? size.width : size.height
        if let side = hide.side {
            return side.isPrimary ? length : 0
        } else {
            if let sideToHide = sideToHide() {
                return sideToHide.isPrimary ? length : 0
            } else {
                return length - pLength(in: size)
            }
        }
    }

    // MARK: Modifiers

    /// Return a new Split with the `splitter` set to a new type.
    ///
    /// If the splitter is a SplitDivider, then get its `visibleThickness` and set it in `styling` before returning.
    public func splitter<T>(@ViewBuilder _ splitter: @escaping () -> T) -> Split<P, T, S> where T: View {
        let newSplitter = splitter()
        if let splitDivider = newSplitter as? (any SplitDivider) {
            styling.visibleThickness = splitDivider.visibleThickness
        }
        return Split<P, T, S>(layout,
                              isResizing: isResizing,
                              fraction: fraction,
                              hide: hide,
                              styling: styling,
                              constraints: constraints,
                              onDrag: onDrag,
                              primary: { primary },
                              splitter: splitter,
                              secondary: { secondary })
    }

    /// Return a new instance of Split with `constraints` set to a SplitConstraints holding these values.
    public func constraints(
        minPFraction: CGFloat? = nil,
        minSFraction: CGFloat? = nil,
        priority: SplitSide? = nil,
        dragToHideP: Bool = false,
        dragToHideS: Bool = false
    ) -> Split {
        let constraints = SplitConstraints(
            minPFraction: minPFraction,
            minSFraction: minSFraction,
            priority: priority,
            dragToHideP: dragToHideP,
            dragToHideS: dragToHideS
        )
        return Split(layout,
                     isResizing: isResizing,
                     fraction: fraction,
                     hide: hide,
                     styling: styling,
                     constraints: constraints,
                     onDrag: onDrag,
                     primary: { primary },
                     splitter: { splitter },
                     secondary: { secondary })
    }

    /// Return a new instance of Split with `constraints` set to this SplitConstraints.
    ///
    /// This is a convenience method for HSplit and VSplit.
    public func constraints(_ constraints: SplitConstraints) -> Split {
        self.constraints(
            minPFraction: constraints.minPFraction,
            minSFraction: constraints.minSFraction,
            priority: constraints.priority,
            dragToHideP: constraints.dragToHideP,
            dragToHideS: constraints.dragToHideS
        )
    }

    /// Return a new instance of Split with `onDrag` set to `callback`.
    ///
    /// The `callback` will be executed as `splitter` is dragged, with the current value of `constrainedFraction`.
    /// Note that `fraction` is different. It is only set when drag ends, and it is used to determine the initial fraction at open.
    ///
    /// This is a convenience method for HSplit and VSplit.
    public func onDrag(_ callback: ((CGFloat) -> Void)?) -> Split {
        return Split(layout,
                     isResizing: isResizing,
                     fraction: fraction,
                     hide: hide,
                     styling: styling,
                     constraints: constraints,
                     onDrag: callback,
                     primary: { primary },
                     splitter: { splitter },
                     secondary: { secondary })
    }

    /// Return a new instance of Split with `styling` set to a SplitStyling holding these values.
    ///
    /// This is a convenience method for `Splitter.line()` which is also used by `Splitter.invisible()`.
    public func styling(
        color: Color? = nil,
        inset: CGFloat? = nil,
        visibleThickness: CGFloat? = nil,
        invisibleThickness: CGFloat? = nil,
        hideSplitter: Bool = false
    ) -> Split {
        let styling = SplitStyling(
            color: color,
            inset: inset,
            visibleThickness: visibleThickness,
            invisibleThickness: invisibleThickness,
            hideSplitter: hideSplitter
        )
        return Split(layout,
                     isResizing: isResizing,
                     fraction: fraction,
                     hide: hide,
                     styling: styling,
                     constraints: constraints,
                     onDrag: onDrag,
                     primary: { primary },
                     splitter: { splitter },
                     secondary: { secondary })
    }

    /// Return a new instance of Split with `styling` set to this SplitStyling.
    ///
    /// This is a convenience method for HSplit and VSplit.
    public func styling(_ styling: SplitStyling) -> Split {
        self.styling(
            color: styling.color,
            inset: styling.inset,
            visibleThickness: styling.visibleThickness,
            invisibleThickness: styling.invisibleThickness,
            hideSplitter: styling.hideSplitter
        )
    }

    /// Return a new instance of Split with `layout` set to this LayoutHolder.
    ///
    /// Split only supports `layout` specified using a LayoutHolder because if you are not going
    /// to change the `layout`, then you should just use HSplit or VSplit.
    public func layout(_ layout: LayoutHolder) -> Split {
        Split(layout,
              isResizing: isResizing,
              fraction: fraction,
              hide: hide,
              styling: styling,
              constraints: constraints,
              onDrag: onDrag,
              primary: { primary },
              splitter: { splitter },
              secondary: { secondary })
    }

    /// Return a new instance of Split with `fraction` set to this FractionHolder.
    public func fraction(_ fraction: FractionHolder) -> Split {
        Split(layout,
              isResizing: isResizing,
              fraction: fraction,
              hide: hide,
              styling: styling,
              constraints: constraints,
              onDrag: onDrag,
              primary: { primary },
              splitter: { splitter },
              secondary: { secondary })
    }

    /// Return a new instance of Split with `fraction` set to a FractionHolder holding onto this CGFloat.
    public func fraction(_ fraction: CGFloat) -> Split {
        self.fraction(FractionHolder(fraction))
    }

    /// Return a new instance of Split with `hide` set to this SideHolder.
    public func hide(_ side: SideHolder) -> Split {
        Split(layout,
              isResizing: isResizing,
              fraction: fraction,
              hide: side,
              styling: styling,
              constraints: constraints,
              onDrag: onDrag,
              primary: { primary },
              splitter: { splitter },
              secondary: { secondary })
    }

    /// Return a new instance of Split with `hide` set to a SideHolder holding onto this SplitSide.
    public func hide(_ side: SplitSide) -> Split {
        hide(SideHolder(side))
    }
}

struct Split_Previews: PreviewProvider {
    static var previews: some View {
        Split(
            primary: { Color.green },
            secondary: {
                Split(
                    primary: { Color.red },
                    secondary: {
                        Split(
                            primary: { Color.blue },
                            secondary: { Color.yellow }
                        )
                        .layout(LayoutHolder(.horizontal))
                    }
                )
                .layout(LayoutHolder(.vertical))
            }
        )
        .layout(LayoutHolder(.horizontal))

        Split(
            primary: {
                Split(primary: { Color.red }, secondary: { Color.green })
                    .layout(LayoutHolder(.vertical))
            },
            secondary: {
                Split(primary: { Color.yellow }, secondary: { Color.blue })
                    .layout(LayoutHolder(.vertical))
            }
        )
        .layout(LayoutHolder(.horizontal))
    }
}
