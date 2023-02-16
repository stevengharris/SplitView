//
//  DemoApp.swift
//  Example
//
//  Created by Steven Harris on 2/4/23.
//

import SwiftUI
import SplitView

struct DemoApp: View {
    @State private var demoID: DemoID = .simpleDefaults
    
    var body: some View {
        let demo = demos[demoID]!
        VStack {
            DemoToolbar(demoID: $demoID)
            switch demoID {
            case .simpleDefaults:
                Color.green
                    .split(.horizontal) { Color.red }
            case .simpleAdjustable:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                let config = SplitConfig(color: .cyan)
                Color.green
                    .split(layout0, hide: hide0, config: config) { Color.red }
            case .nestedAdjustable:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                let layout1 = demo.holders[1].layout
                let hide1 = demo.holders[1].hide
                let layout2 = demo.holders[2].layout
                let hide2 = demo.holders[2].hide
                let config = SplitConfig(minPFraction: 0.2, minSFraction: 0.1)
                Color.green
                    .split(layout0, hide: hide0) {
                        Color.red
                            .split(layout1, hide: hide1) {
                                Color.blue
                                    .split(layout2, hide: hide2, config: config) {
                                        Color.yellow
                                    }
                            }
                    }
            case .invisibleSplitter:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                let config = SplitConfig(minPFraction: 0.2, minSFraction: 0.2)
                Color.green
                    .split(
                        layout0,
                        hide: hide0,
                        config: config,
                        splitter: { Splitter.invisible(layout0) },
                        secondary: { Color.red }
                    )
            case .customSplitter:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                Color.green
                    .split(
                        layout0,
                        hide: hide0,
                        splitter: { DemoSplitter(layout: layout0, hide: hide0) },
                        secondary: { Color.red }
                    )
            case .sidebars:
                let leftItems = ["Master Item 1", "Master Item 2", "Master Item 3", "Master Item 4"]
                let leftConfig = SplitConfig(minPFraction: 0.15, minSFraction: 0.15, priority: .primary)
                let middleText = "Note how each sidebar can be resized without affecting the other one, and how the window can be resized while both sidebars remain the same size."
                let rightHide = demo.holders[0].hide
                let layout = demo.holders[0].layout
                let rightConfig = SplitConfig(minPFraction: 0.3, minSFraction: 0.15, priority: .secondary)
                let rightText = "Here is some metadata about what's showing in the middle that you want to hide/show."
                List(leftItems, id: \.self) { item in
                    Text(item)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .listStyle(.plain)
                .padding([.top], 8)
                .split(
                    layout,
                    fraction: 0.2,
                    config: leftConfig,
                    splitter: { Splitter.line(layout) },
                    secondary: {
                        VStack {
                            Text(middleText)
                            Spacer()
                        }
                        .padding(8)
                        .split(
                            layout,
                            fraction: 0.8,
                            hide: rightHide,
                            config: rightConfig,
                            splitter: { Splitter.line(layout) },
                            secondary: {
                                VStack {
                                    Text(rightText)
                                    Spacer()
                                }
                                .padding(8)
                            }
                        )
                    }
                )
                .border(.black)
                .padding([.leading, .trailing], 8)
            }
            Text(demo.description)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
        }
    }
    
}

struct DemoApp_Previews: PreviewProvider {
    static var previews: some View {
        DemoApp()
    }
}
