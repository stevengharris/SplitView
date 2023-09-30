//
//  HSplit.swift
//  SplitView
//
//  Created by Steven Harris on 3/1/23.
//

import SwiftUI

public struct HSplit<P: View, D: View, S: View>: View {
    private let isResizing: Bool
    private let fraction: FractionHolder
    private let hide: SideHolder
    private let styling: SplitStyling
    private let constraints: SplitConstraints
    private let onDrag: ((CGFloat) -> Void)?
    private let primary: P
    private let splitter: D
    private let secondary: S

    public var body: some View {
        Split(primary: { primary }, secondary: { secondary })
            .layout(LayoutHolder(.horizontal))
            .styling(styling)
            .constraints(constraints)
            .onDrag(onDrag)
            .splitter {
                splitter
                    .environmentObject(styling)
            }
            .fraction(fraction)
            .hide(hide)
    }

    public init(
        isResizing: Bool = true,
        @ViewBuilder left: @escaping () -> P,
        @ViewBuilder right: @escaping () -> S
    ) where D == Splitter {
        let fraction = FractionHolder()
        let hide = SideHolder()
        let styling = SplitStyling()
        let constraints = SplitConstraints()
        self.init(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: nil,
            primary: { left() },
            splitter: { D() },
            secondary: { right() }
        )
    }

    private init(
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
        self.isResizing = isResizing
        self.fraction = fraction
        self.hide = hide
        self.styling = styling
        self.constraints = constraints
        self.onDrag = onDrag
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
    }

    // MARK: Modifiers

    // Note: Modifiers return a new HSplit instance with the same state except for what is
    // being modified.

    /// Return a new HSplit with the `splitter` set to a new type.
    ///
    /// If the splitter is a SplitDivider, get its visibleThickness and set that in `styling` before returning.
    public func splitter<T>(@ViewBuilder _ splitter: @escaping () -> T) -> HSplit<P, T, S> where T: View {
        let newSplitter = splitter()
        if let splitDivider = newSplitter as? (any SplitDivider) {
            styling.visibleThickness = splitDivider.visibleThickness
        }
        return HSplit<P, T, S>(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: splitter,
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `constraints` set to these values.
    public func constraints(
        minPFraction: CGFloat? = nil,
        minSFraction: CGFloat? = nil,
        priority: SplitSide? = nil,
        dragToHideP: Bool = false,
        dragToHideS: Bool = false
    ) -> HSplit {
        let constraints = SplitConstraints(
            minPFraction: minPFraction,
            minSFraction: minSFraction,
            priority: priority,
            dragToHideP: dragToHideP,
            dragToHideS: dragToHideS
        )
        return HSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `onDrag` set to `callback`.
    ///
    /// The `callback` will be executed as `splitter` is dragged, with the current value of `privateFraction`.
    /// Note that `fraction` is different. It is only set when drag ends, and it is used to determine the initial fraction at open.
    public func onDrag(_ callback: ((CGFloat) -> Void)?) -> HSplit {
        return HSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: callback,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `styling` set to these values.
    public func styling(
        color: Color? = nil,
        inset: CGFloat? = nil,
        visibleThickness: CGFloat? = nil,
        invisibleThickness: CGFloat? = nil,
        hideSplitter: Bool = false
    ) -> HSplit {
        let styling = SplitStyling(
            color: color,
            inset: inset,
            visibleThickness: visibleThickness,
            invisibleThickness: invisibleThickness,
            hideSplitter: hideSplitter
        )
        return HSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `fraction` set to this FractionHolder
    public func fraction(_ fraction: FractionHolder) -> HSplit<P, D, S> {
        HSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: hide,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `fraction` set to a FractionHolder holding onto this CGFloat
    public func fraction(_ fraction: CGFloat) -> HSplit<P, D, S> {
        self.fraction(FractionHolder(fraction))
    }

    /// Return a new instance of HSplit with `hide` set to this SideHolder
    public func hide(_ side: SideHolder) -> HSplit<P, D, S> {
        HSplit(
            isResizing: isResizing,
            fraction: fraction,
            hide: side,
            styling: styling,
            constraints: constraints,
            onDrag: onDrag,
            primary: { primary },
            splitter: { splitter },
            secondary: { secondary }
        )
    }

    /// Return a new instance of HSplit with `hide` set to a SideHolder holding onto this SplitSide
    public func hide(_ side: SplitSide) -> HSplit<P, D, S> {
        hide(SideHolder(side))
    }
}

struct HSplit_Previews: PreviewProvider {
    static var previews: some View {
        HSplit(
            left: { Color.green },
            right: {
                VSplit(
                    top: { Color.red },
                    bottom: {
                        HSplit(
                            left: { Color.blue },
                            right: { Color.yellow }
                        )
                    }
                )
            }
        )

        HSplit(
            left: {
                VSplit(top: { Color.red }, bottom: { Color.green })
            },
            right: {
                VSplit(top: { Color.yellow }, bottom: { Color.blue })
            }
        )
    }
}
