//
//  SplitConstraints.swift
//  SplitView
//
//  Created by Steven Harris on 2/13/23.
//

import SwiftUI

public struct SplitConstraints {
    /// The minimum fraction that the primary view will be constrained within. A value of `nil` means unconstrained.
    var minPFraction: CGFloat?
    /// The minimum fraction that the secondary view will be constrained within. A value of `nil` means unconstrained.
    var minSFraction: CGFloat?
    /// The side that should have sizing priority (i.e., stay fixed) as the containing view is resized. A value of `nil` means the fraction remains unchanged.
    var priority: SplitSide?
    /// Whether to hide the primary side when dragging stops past minPFraction
    var hideAtMinP: Bool
    /// Whether to hide the secondary side when dragging stops past minSFraction
    var hideAtMinS: Bool
    
    public init(minPFraction: CGFloat? = nil, minSFraction: CGFloat? = nil, priority: SplitSide? = nil, hideAtMinP: Bool = false, hideAtMinS: Bool = false) {
        self.minPFraction = minPFraction
        self.minSFraction = minSFraction
        self.priority = priority
        // Note: minPFraction/minSFraction must be specified if hideAtMinP/hideAtMinS is true,
        // else hideAtMinP/hideAtMinS are ignored.
        self.hideAtMinP = hideAtMinP
        self.hideAtMinS = hideAtMinS
    }
}
