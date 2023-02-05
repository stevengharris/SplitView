//
//  SplitModifiers.swift
//  
//
//  Created by Steven Harris on 2/2/23.
//

import SwiftUI

/// A ViewModifier to split Content horizontally with `secondary` at `fraction` and both views showing by default.
public struct HSplit<S: View>: ViewModifier {
    var fraction: SplitFraction?
    var hide: SplitHide?
    var secondary: ()->S
    
    public func body(content: Content) -> some View {
        SplitView(layout: .Horizontal, fraction: fraction, hide: hide, primary: {content}, secondary: secondary)
    }
    
    public init(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (()->S)) {
        self.fraction = fraction
        self.hide = hide
        self.secondary = secondary
    }
}

/// A ViewModifier to split Content vertically with `secondary` at `fraction` both views showing by default.
public struct VSplit<S: View>: ViewModifier {
    var fraction: SplitFraction?
    var hide: SplitHide?
    var secondary: ()->S
    
    public func body(content: Content) -> some View {
        SplitView(layout: .Vertical, fraction: fraction, hide: hide, primary: {content}, secondary: secondary)
    }
    
    public init(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (()->S)) {
        self.fraction = fraction
        self.hide = hide
        self.secondary = secondary
    }
}

extension View {
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func hSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: hide, secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying only `fraction` as a SplitFraction.
    public func hSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying only `hide` as a SplitHide.
    public func hSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying only `fraction` as a CGFloat.
    public func hSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func hSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary
    /// using defaults for `fraction` and `hide`.
    public func hSplit(@ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying `fraction` as a SplitFraction and `hide` as a SplitHide.
    public func vSplit(fraction: SplitFraction, hide: SplitHide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: hide, secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying only `fraction` as a SplitFraction.
    public func vSplit(fraction: SplitFraction, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: SplitHide(nil), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying only `hide` as a SplitHide.
    public func vSplit(hide: SplitHide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: hide, secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying `fraction` as a CGFloat and `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(fraction: CGFloat, hide: SplitSide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(hide), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying only `fraction` as a CGFloat.
    public func vSplit(fraction: CGFloat, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(fraction), hide: SplitHide(nil), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`
    /// specifying only `hide` as a SplitSide (i.e., .Primary or .Secondary).
    public func vSplit(hide: SplitSide, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(hide), secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary
    /// using defaults for `fraction` and `hide`.
    public func vSplit(@ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: SplitFraction(nil), hide: SplitHide(nil), secondary: secondary))
    }
    
}
