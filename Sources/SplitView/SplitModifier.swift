//
//  SplitModifier.swift
//  
//
//  Created by Steven Harris on 2/2/23.
//

import SwiftUI

/// A ViewModifier to split Content in `layout` direction with `secondary` at `fraction` and both views showing by default.
///
/// The views are separated by `spacing`, with `splitter` sitting in the space.
public struct Split<S: View, D: View>: ViewModifier {
    let layout: LayoutHolder
    let spacing: CGFloat?
    let fraction: FractionHolder
    let hide: SideHolder
    let secondary: ()->S
    let splitter: ()->D
    
    public func body(content: Content) -> some View {
        SplitView(layout, spacing: spacing, fraction: fraction, hide: hide, primary: {content}, splitter: splitter, secondary: secondary)
    }
    
    public init(_ layout: LayoutHolder, spacing: CGFloat? = nil, fraction: FractionHolder, hide: SideHolder, @ViewBuilder splitter: @escaping (()->D), @ViewBuilder secondary: @escaping (()->S)) {
        self.layout = layout
        self.spacing = spacing
        self.fraction = fraction
        self.hide = hide
        self.splitter = splitter
        self.secondary = secondary
    }
}


/// Why so many View extensions!?!?
///
/// It's a mess to deal with optional ViewBuilders, and in the end it's clearer just to overload the inits with
/// explicit arguments even if it results in a bunch of tedious boilerplate.

//MARK: Using SplitLayout

extension View {
    
    //MARK: Using defaults
    
    // Following 2 cases let `fraction` and `hide` default, with `splitter` either defaulting or custom.

    /// Neither `fraction` nor `hide` specified, default Splitter.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: SplitLayout, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        return modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Neither `fraction` nor `hide` specified, custom `splitter`.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: SplitLayout, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using FractionHolder and SideHolder
    
    // Following six cases let `fraction` and/or `hide` be specified using FractionHolder and SideHolder, with `splitter` either defaulting or custom.
    
    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, hide: SideHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: hide, splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, hide: SideHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: hide, splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SideHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: hide, splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SideHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: hide, splitter: splitter, secondary: secondary))
    }

    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: SideHolder(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using CGFloat and SplitSide
    
    //Following six cases let `fraction` and/or `hide` be specified using CGFloat and SplitSide, with `splitter` either defaulting or custom.

    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: SplitLayout, fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(hide), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: SplitLayout, fraction: CGFloat, hide: SplitSide, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(hide), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(hide), splitter: { Splitter(layout) }, secondary: secondary))
    }

    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SplitSide, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(hide), splitter: splitter, secondary: secondary))
    }
    
    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: CGFloat, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(), splitter: splitter, secondary: secondary))
    }

}

//MARK: Using LayoutHolder

extension View {
    
    //MARK: Using defaults
    
    // Following 2 cases let `fraction` and `hide` default, with `splitter` either defaulting or custom.

    /// Neither `fraction` nor `hide` specified, default Splitter.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: LayoutHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Neither `fraction` nor `hide` specified, custom `splitter`.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: LayoutHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using FractionHolder and SideHolder
    
    // Following six cases let `fraction` and/or `hide` be specified using FractionHolder and SideHolder, with `splitter` either defaulting or custom.
    
    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: hide, splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: hide, splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SideHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: hide, splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SideHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: hide, splitter: splitter, secondary: secondary))
    }

    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: SideHolder(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using CGFloat and SplitSide
    
    //Following six cases let `fraction` and/or `hide` be specified using CGFloat and SplitSide, with `splitter` either defaulting or custom.

    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(hide), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, hide: SplitSide, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(hide), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(hide), splitter: { Splitter(layout) }, secondary: secondary))
    }

    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SplitSide, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(hide), splitter: splitter, secondary: secondary))
    }
    
    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(), splitter: { Splitter(layout) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, @ViewBuilder splitter: @escaping (()->some View), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(), splitter: splitter, secondary: secondary))
    }

}
