//
//  VSplit.swift
//  SplitView
//
//  Created by Steven Harris on 3/3/23.
//

import SwiftUI

public struct VSplit<P: View, D: View, S: View>: View {
    private let fraction: FractionHolder
    private let hide: SideHolder
    private let styling: SplitStyling
    private let constraints: SplitConstraints
    private let primary: P
    private let splitter: D
    private let secondary: S
    
    public var body: some View {
        Split(primary: { primary }, secondary: { secondary })
            .layout(.vertical)
            .styling(styling)
            .constraints(constraints)
            .splitter {
                splitter
                    .environmentObject(styling)
            }
            .fraction(fraction)
            .hide(hide)
    }
    
    public init(@ViewBuilder primary: @escaping ()->P, @ViewBuilder secondary: @escaping ()->S) where D == Splitter {
        let fraction = FractionHolder()
        let hide = SideHolder()
        let styling = SplitStyling()
        let constraints = SplitConstraints()
        self.init(fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary() }, splitter: { D() }, secondary: { secondary() })
    }
    
    private init(fraction: FractionHolder, hide: SideHolder, styling: SplitStyling, constraints: SplitConstraints, @ViewBuilder primary: @escaping ()->P, @ViewBuilder splitter: @escaping ()->D, @ViewBuilder secondary: @escaping ()->S) {
        self.fraction = fraction
        self.hide = hide
        self.styling = styling
        self.constraints = constraints
        self.primary = primary()
        self.splitter = splitter()
        self.secondary = secondary()
    }
    
    //MARK: Modifiers
    
    // Note: Modifiers return a new VSplit instance with the same state except for what is
    // being modified.
    
    /// Return a new VSplit with the `splitter` set to a new type.
    ///
    /// If the splitter is a SplitDivider, get its `visibleThickness` and set that in `styling` before returning.
    public func splitter<T>(@ViewBuilder _ splitter: @escaping ()->T) -> VSplit<P, T, S> where T: View {
        let newSplitter = splitter()
        if let splitDivider = newSplitter as? (any SplitDivider) {
            styling.visibleThickness = splitDivider.visibleThickness
        }
        return VSplit<P, T, S>(fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: splitter, secondary: { secondary })
    }
    
    public func constraints(minPFraction: CGFloat? = nil, minSFraction: CGFloat? = nil, priority: SplitSide? = nil) -> VSplit {
        let constraints = SplitConstraints(minPFraction: minPFraction, minSFraction: minSFraction, priority: priority)
        return VSplit(fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    public func styling(color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) -> VSplit {
        let styling = SplitStyling(color: color, inset: inset, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness)
        return VSplit(fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of VSplit with `fraction` set to this FractionHolder
    public func fraction(_ fraction: FractionHolder) -> VSplit<P, D, S> {
        VSplit(fraction: fraction, hide: hide, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of VSplit with `fraction` set to a FractionHolder holding onto this CGFloat
    public func fraction(_ fraction: CGFloat) -> VSplit<P, D, S> {
        self.fraction(FractionHolder(fraction))
    }

    /// Return a new instance of VSplit with `hide` set to this SideHolder
    public func hide(_ side: SideHolder) -> VSplit<P, D, S> {
        VSplit(fraction: fraction, hide: side, styling: styling, constraints: constraints, primary: { primary }, splitter: { splitter }, secondary: { secondary })
    }
    
    /// Return a new instance of VSplit with `hide` set to a SideHolder holding onto this SplitSide
    public func hide(_ side: SplitSide) -> VSplit<P, D, S> {
        self.hide(SideHolder(side))
    }
    
}
