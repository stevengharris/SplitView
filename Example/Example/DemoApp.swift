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
                    .split(.Horizontal) { Color.red }
            case .simpleAdjustable:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                Color.green
                    .split(layout0, hide: hide0) { Color.red }
            case .nestedAdjustable:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                let layout1 = demo.holders[1].layout
                let hide1 = demo.holders[1].hide
                let layout2 = demo.holders[2].layout
                let hide2 = demo.holders[2].hide
                Color.green
                    .split(layout0, hide: hide0) {
                        Color.red
                            .split(layout1, hide: hide1) {
                                Color.blue
                                    .split(layout2, hide: hide2) {
                                        Color.yellow
                                    }
                            }
                    }
            case .invisibleSplitter:
                Color.green
                    .split(
                        .Horizontal,
                        splitter: { Splitter(.Horizontal, visibleThickness: 0) },
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
