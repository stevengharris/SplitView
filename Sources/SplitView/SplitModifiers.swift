//
//  SplitModifiers.swift
//  
//
//  Created by Steven Harris on 2/2/23.
//

import SwiftUI

/// A ViewModifier to split Content horizontally with `secondary` at `fraction` and both views showing by default.
public struct HSplit<S: View, D: View>: ViewModifier {
    var fraction: SplitFraction?
    var hide: SplitHide?
    var secondary: ()->S
    var splitter: ()->D
    
    public func body(content: Content) -> some View {
        SplitView(layout: .Horizontal, fraction: fraction, hide: hide, primary: {content}, secondary: secondary, splitter: splitter)
    }
    
    public init(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (()->S), splitter: @escaping (()->D)) {
        self.fraction = fraction
        self.hide = hide
        self.secondary = secondary
        self.splitter = splitter
    }
}

/// A ViewModifier to split Content vertically with `secondary` at `fraction` both views showing by default.
public struct VSplit<S: View, D: View>: ViewModifier {
    var fraction: SplitFraction?
    var hide: SplitHide?
    var secondary: ()->S
    var splitter: ()->D
    
    public func body(content: Content) -> some View {
        SplitView(layout: .Vertical, fraction: fraction, hide: hide, primary: {content}, secondary: secondary, splitter: splitter)
    }
    
    public init(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (()->S), splitter: @escaping (()->D)) {
        self.fraction = fraction
        self.hide = hide
        self.secondary = secondary
        self.splitter = splitter
    }
}

extension View {
    
    /*
     Why so many ViewModifiers!?
     
     It's a mess to deal with optional ViewBuilders, and in the end it's clearer just to overload the inits with
     explicit arguments. This way we can do everything from the simplest...
     
        Color.green.hSplit(0.25)   // Open at 1/4 of the width, slide the Splitter but no state retention
     
     to the elaborate...
     
        Color.green
            .hSplit(
                fraction: gFraction,                // An instance of SplitFraction
                hide: gHide,                        // An instance of SplitHide
                secondary: { Color.yellow },
                splitter: { MyCustomSplitter() }    // A custom View for a splitter
            )
     */
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func hSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: hide, secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func hSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: hide, secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// specifying only `fraction` as a SplitFraction.
    public func hSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `fraction` as a SplitFraction.
    public func hSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// specifying only `hide` as a SplitHide.
    public func hSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `hide` as a SplitHide.
    public func hSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` using `Splitter.horizontal`
    /// specifying only `fraction` as a CGFloat.
    public func hSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `fraction` as a CGFloat.
    public func hSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `Splitter.horizontal`
    /// using defaults for `fraction` and `hide`.
    public func hSplit(@ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.horizontal }))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary` with `splitter`
    /// using defaults for `fraction` and `hide`.
    public func hSplit(@ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func vSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: hide, secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func vSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: hide, secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying only `fraction` as a SplitFraction.
    public func vSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `fraction` as a SplitFraction.
    public func vSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying only `hide` as a SplitHide.
    public func vSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `hide` as a SplitHide.
    public func vSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying only `fraction` as a CGFloat.
    public func vSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `fraction` as a CGFloat.
    public func vSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary, splitter: splitter))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `Splitter.vertical`
    /// using defaults for `fraction` and `hide`.
    public func vSplit(@ViewBuilder secondary: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary, splitter: { Splitter.vertical }))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary` with `splitter`
    /// using defaults for `fraction` and `hide`.
    public func vSplit(@ViewBuilder secondary: @escaping (()->some View), splitter: @escaping (()->some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary, splitter: splitter))
    }
    
}
