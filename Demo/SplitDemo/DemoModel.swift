//
//  DemoModel.swift
//  Example
//
//  Created by Steven Harris on 2/10/23.
//

import Foundation
import SplitView

/// Identifiers for the demos
enum DemoID: String, CaseIterable {
    case simpleDefaults
    case simpleAdjustable
    case nestedAdjustable
    case invisibleSplitter
    case customSplitter
    case sidebars
}

/// Globally accessible dictionary of Demos.
///
/// The `label` is used for the Menu, `description` for the Text at the bottom.
///
/// The `holders` identify the LayoutHolder and SideHolders that can be used to control
/// the various Split views in the demo. These need to be defined once, so that the
/// DemoToolbar at the top and the individual Split views are holding onto the same
/// ObservableObject.
let demos: [DemoID : Demo] = [
    .simpleDefaults :
        Demo(
            label: "Simple defaults",
            accessibilityIdentifier: "simpleDefaults",
            description: "Split view with the default Splitter."
        ),
    .simpleAdjustable :
        Demo(
            label: "Simple adjustable",
            accessibilityIdentifier: "simpleAdjustable",
            description: "Adjustable split view with cyan default Splitter",
            holders: [SplitStateHolder(layout: LayoutHolder(), hide: SideHolder(), accessibilityIdentifier: "HHide")]
        ),
    .nestedAdjustable :
        Demo(
            label: "Nested adjustable",
            accessibilityIdentifier: "nestedAdjustable",
            description: "Nested adjustable split views with the default Splitter",
            holders: [
                SplitStateHolder(layout: LayoutHolder(), hide: SideHolder(), accessibilityIdentifier: "HHide"),
                SplitStateHolder(layout: LayoutHolder(.vertical), hide: SideHolder(), accessibilityIdentifier: "SVHide"),
                SplitStateHolder(layout: LayoutHolder(.horizontal), hide: SideHolder(), accessibilityIdentifier: "SHHide"),
            ]
        ),
    .invisibleSplitter:
        Demo(
            label: "Invisible splitter",
            accessibilityIdentifier: "invisibleSplitter",
            description: "Invisible splitter with constraints.",
            holders: [SplitStateHolder(layout: LayoutHolder(), hide: SideHolder(), accessibilityIdentifier: "HHide")]
        ),
    .customSplitter:
        Demo(
            label: "Custom splitter",
            accessibilityIdentifier: "customSplitter",
            description: "Custom splitter that adjusts to layout/hide.",
            holders: [SplitStateHolder(layout: LayoutHolder(.horizontal), hide: SideHolder(), accessibilityIdentifier: "HHide")]
        ),
    .sidebars:
        Demo(
            label: "Sidebars",
            accessibilityIdentifier: "sidebars",
            description: "Opposing sidebar maintains its size as either is resized.",
            holders: [SplitStateHolder(layout: LayoutHolder(.horizontal), hide: SideHolder(), accessibilityIdentifier: "DHide")]
        ),
    
]

/// Demo holds onto the labels for the Menu and descriptions for the Text at the bottom, along with
/// the SplitStateHolders that are used by the DemoToolbar buttons and the Split views themselves.
struct Demo {
    var label: String
    var accessibilityIdentifier: String // New property for accessibility identifier
    var description: String
    var holders: [SplitStateHolder] = []
}

/// The combination of LayoutHolder and SideHolder used in one Split view.
///
/// Has to be Identifiable because we ForEach over the `demo.holders` to create the
/// Buttons dynamically.
struct SplitStateHolder: Identifiable {
    var id: UUID = UUID()
    var layout: LayoutHolder
    var hide: SideHolder
    var accessibilityIdentifier: String // New property for accessibility identifier
}

