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
                HSplit(
                    left: { Color.green },
                    right: { Color.red }
                )
            case .simpleAdjustable:
                Split(
                    primary: { Color.green },
                    secondary: { Color.red }
                )
                .styling(color: .yellow)
                .layout(demo.holders[0].layout)
                .hide(demo.holders[0].hide)
            case .nestedAdjustable:
                Split(
                    primary: { Color.green },
                    secondary: {
                        Split(
                            primary: { Color.red },
                            secondary: {
                                Split(
                                    primary: { Color.blue },
                                    secondary: { Color.yellow }
                                )
                                .constraints(minPFraction: 0.2, minSFraction: 0.1)
                                .styling(hideSplitter: true)
                                .layout(demo.holders[2].layout)
                                .hide(demo.holders[2].hide)
                            }
                        )
                        .styling(hideSplitter: true)
                        .layout(demo.holders[1].layout)
                        .hide(demo.holders[1].hide)
                    }
                )
                .styling(hideSplitter: true)
                .layout(demo.holders[0].layout)
                .hide(demo.holders[0].hide)
            case .invisibleSplitter:
                Split(
                    primary: { Color.green },
                    secondary: { Color.red }
                )
                .splitter { Splitter.invisible() }
                .constraints(minPFraction: 0.2, minSFraction: 0.2, dragToHideS: true)
                .layout(demo.holders[0].layout)
                .hide(demo.holders[0].hide)
            case .customSplitter:
                let layout0 = demo.holders[0].layout
                let hide0 = demo.holders[0].hide
                Split(
                    primary: { Color.green },
                    secondary: { Color.red }
                )
                .splitter { DemoSplitter(layout: layout0, hide: hide0) }
                .layout(layout0)
                .hide(hide0)
            case .sidebars:
                let leftItems = ["Master Item 1", "Master Item 2", "Master Item 3", "Master Item 4"]
                let middleText = "Note how each sidebar can be resized without affecting the other one, and how the window can be resized while both sidebars remain the same size."
                let rightText = "Here is some metadata about what's showing in the middle that you want to hide/show."
                Split(
                    primary: {
                        List(leftItems, id: \.self) { item in
                            Text(item)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .listStyle(.plain)
                        .padding([.top], 8)
                    },
                    secondary: {
                        Split(
                            primary: {
                                VStack {
                                    Text(middleText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                                .padding(8)
                            },
                            secondary: {
                                VStack {
                                    Text(rightText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                                .padding(8)
                            }
                        )
                        .splitter { Splitter.line() }
                        .constraints(minPFraction: 0.3, minSFraction: 0.2, priority: .secondary, dragToHideS: true)
                        .layout(demo.holders[0].layout)
                        .fraction(0.75)
                        .hide(demo.holders[0].hide)
                    }
                )
                .splitter { Splitter.line() }
                .constraints(minPFraction: 0.15, minSFraction: 0.15, priority: .primary)
                .layout(demo.holders[0].layout)
                .fraction(0.2)
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
