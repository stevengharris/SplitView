//
//  SplitConfig.swift
//  SplitView
//  
//
//  Created by Steven Harris on 2/13/23.
//

import SwiftUI

/// A configuration that can be supplied via the `split` view modifer to specify various options.
///
/// Note that the default values of `color` etc for the default Splitter are specified in the Splitter itself and be overridden here.
public struct SplitConfig {
    /// The minimum fraction that the primary view will be constrained within. A value of `nil` means unconstrained.
    public var minPFraction: CGFloat?
    /// The minimum fraction that the secondary view will be constrained within. A value of `nil` means unconstrained.
    public var minSFraction: CGFloat?
    /// The color of the default Splitter.
    public var color: Color
    /// The inset for the visible part of the default Splitter from the ends it reaches to.
    public var inset: CGFloat
    /// The visible thickness of the default Splitter and the `spacing` between the `primary` and `secondary` views.
    public var visibleThickness: CGFloat
    /// The thickness across which the dragging will be detected.
    public var invisibleThickness: CGFloat
    
    public init(minPFraction: CGFloat? = nil, minSFraction: CGFloat? = nil, color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) {
        self.minPFraction = minPFraction
        self.minSFraction = minSFraction
        self.color = color ?? Splitter.defaultColor
        self.inset = inset ?? Splitter.defaultInset
        self.visibleThickness = visibleThickness ?? Splitter.defaultVisibleThickness
        self.invisibleThickness = invisibleThickness ?? Splitter.defaultInvisibleThickness
    }
}
