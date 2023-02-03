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
    
    /// Return a `SplitView(layout: .Horizontal)` split between the `primary` View (self) and `secondary`.
    public func hSplit(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(HSplit(fraction: fraction, hide: hide, secondary: secondary))
    }
    
    /// Return a `SplitView(layout: .Vertical)` split between the `primary` View (self) and `secondary`.
    public func vSplit(fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder secondary: @escaping (() -> some View)) -> some View {
        modifier(VSplit(fraction: fraction, hide: hide, secondary: secondary))
    }
}


