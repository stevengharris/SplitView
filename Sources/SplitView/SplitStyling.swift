//
//  SplitStyling.swift
//  SplitView
//
//  Created by Steven Harris on 3/6/23.
//

import SwiftUI

public class SplitStyling: ObservableObject {
    var color: Color
    /// The inset for the visible part of the default Splitter from the ends it reaches to.
    var inset: CGFloat
    /// The visible thickness of the default Splitter and the `spacing` between the `primary` and `secondary` views.
    var visibleThickness: CGFloat
    /// The thickness across which the dragging will be detected.
    var invisibleThickness: CGFloat
    
    public init(color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) {
        self.color = color ?? Splitter.defaultColor
        self.inset = inset ?? Splitter.defaultInset
        self.visibleThickness = visibleThickness ?? Splitter.defaultVisibleThickness
        self.invisibleThickness = invisibleThickness ?? Splitter.defaultInvisibleThickness
    }
}
