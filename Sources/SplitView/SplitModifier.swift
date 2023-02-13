//
//  SplitModifier.swift
//  SplitView
//
//  Created by Steven Harris on 2/2/23.
//

import SwiftUI

/// A ViewModifier to split Content in `layout` direction with `secondary` at `fraction` and both views showing by default.
///
/// The views are separated by `spacing`, with `splitter` sitting in the space.
public struct Split<S: View, D: SplitDivider>: ViewModifier {
    let layout: LayoutHolder
    let fraction: FractionHolder
    let hide: SideHolder
    let config: SplitConfig
    let secondary: ()->S
    let splitter: ()->D
    
    public func body(content: Content) -> some View {
        SplitView(layout, fraction: fraction, hide: hide, config: config, primary: {content}, splitter: splitter, secondary: secondary)
    }
    
    public init(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, config: SplitConfig, @ViewBuilder splitter: @escaping (()->D), @ViewBuilder secondary: @escaping (()->S)) {
        self.layout = layout
        self.fraction = fraction
        self.hide = hide
        self.config = config
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
    public func split(_ layout: SplitLayout, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        return modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Neither `fraction` nor `hide` specified, custom `splitter`.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: SplitLayout, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using FractionHolder and SideHolder
    
    // Following six cases let `fraction` and/or `hide` be specified using FractionHolder and SideHolder, with `splitter` either defaulting or custom.
    
    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: hide, config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: hide, config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: hide, config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: hide, config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }

    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: FractionHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: fraction, hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using CGFloat and SplitSide
    
    //Following six cases let `fraction` and/or `hide` be specified using CGFloat and SplitSide, with `splitter` either defaulting or custom.

    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: SplitLayout, fraction: CGFloat, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: SplitLayout, fraction: CGFloat, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }

    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: SplitLayout, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: CGFloat, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: SplitLayout, fraction: CGFloat, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(LayoutHolder(layout), fraction: FractionHolder(fraction), hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }

}

//MARK: Using LayoutHolder

extension View {
    
    //MARK: Using defaults
    
    // Following 2 cases let `fraction` and `hide` default, with `splitter` either defaulting or custom.

    /// Neither `fraction` nor `hide` specified, default Splitter.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: LayoutHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Neither `fraction` nor `hide` specified, custom `splitter`.
    ///
    /// Views will be split in middle with both views showing.
    public func split(_ layout: LayoutHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using FractionHolder and SideHolder
    
    // Following six cases let `fraction` and/or `hide` be specified using FractionHolder and SideHolder, with `splitter` either defaulting or custom.
    
    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: hide, config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: hide, config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: hide, config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SideHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: hide, config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }

    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: FractionHolder, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: fraction, hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    //MARK: Using CGFloat and SplitSide
    
    //Following six cases let `fraction` and/or `hide` be specified using CGFloat and SplitSide, with `splitter` either defaulting or custom.

    /// Both `fraction` and `hide` specified, default Splitter.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Both `fraction` and `hide` specified, custom `splitter`.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `hide` specified, default Splitter.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }

    /// Only `hide` specified, custom `splitter`.
    ///
    /// Views will be split in the middle, with the `hide`side hidden.
    public func split(_ layout: LayoutHolder, hide: SplitSide, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(), hide: SideHolder(hide), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }
    
    /// Only `fraction` specified, default Splitter.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, config: SplitConfig? = nil, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(), config: config ?? SplitConfig(), splitter: { Splitter(layout, config: config ?? SplitConfig()) }, secondary: secondary))
    }
    
    /// Only `fraction` specific, custom `splitter`.
    ///
    /// Both views will be showing, split at `fraction` of the width/height.
    public func split(_ layout: LayoutHolder, fraction: CGFloat, config: SplitConfig? = nil, @ViewBuilder splitter: @escaping (()->some SplitDivider), @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(Split(layout, fraction: FractionHolder(fraction), hide: SideHolder(), config: config ?? SplitConfig(), splitter: splitter, secondary: secondary))
    }

}
