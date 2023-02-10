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
}

/// Globally accessible dictionary of Demos.
///
/// The `label` is used for the Menu, `description` for the Text at the bottom.
///
/// The `holders` identify the LayoutHolder and SideHolders that can be used to control
/// the various SplitViews in the demo. These need to be defined once, so that the
/// DemoToolbar at the top and the individual SplitViews are holding onto the same
/// ObservableObject.
let demos: [DemoID : Demo] = [
    .simpleDefaults :
        Demo(
            label: "Simple defaults",
            description: "Single split view with the default Splitter."
        ),
    .simpleAdjustable :
        Demo(
            label: "Simple adjustable",
            description: "Single adjustable split view with the default Splitter",
            holders: [SplitStateHolder(layout: LayoutHolder(), hide: SideHolder())]
        ),
    .nestedAdjustable :
        Demo(
            label: "Nested adjustable",
            description: "Nested adjustable split views with the default Splitter",
            holders: [
                SplitStateHolder(layout: LayoutHolder(), hide: SideHolder()),
                SplitStateHolder(layout: LayoutHolder(.Vertical), hide: SideHolder()),
                SplitStateHolder(layout: LayoutHolder(.Horizontal), hide: SideHolder()),
            ]
        ),
    .invisibleSplitter:
        Demo(
            label: "Invisible splitter",
            description: "Single split view with invisible splitter."
        ),
    .customSplitter:
        Demo(
            label: "Custom splitter",
            description: "Single adjustable split view with a custom splitter.",
            holders: [SplitStateHolder(layout: LayoutHolder(.Horizontal), hide: SideHolder())]
        ),
]

/// Demo holds onto the labels for the Menu and descriptions for the Text at the bottom, along with
/// the SplitStateHolders that are used by the DemoToolbar buttons and the SplitViews themselves.
struct Demo {
    var label: String
    var description: String
    var holders: [SplitStateHolder] = []
}

/// The combination of LayoutHolder and SideHolder used in one SplitView.
///
/// Has to be Identifiable because we ForEach over the `demo.holders` to create the
/// Buttons dynamically.
struct SplitStateHolder: Identifiable {
    var id: UUID = UUID()
    var layout: LayoutHolder
    var hide: SideHolder
}

