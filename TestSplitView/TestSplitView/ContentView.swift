//
//  ContentView.swift
//  TestSplitView
//
//  Created by Steven Harris on 1/18/23.
//

import SwiftUI
import SplitView

struct ContentView: View {
    // Use the following to get/set from UserDefaults.standard
    /*
    let rFraction = SplitFraction.usingUserDefaults(key: "rFraction")
    let rHide = SplitHide.usingUserDefaults(key: "rHide")
    let bFraction = SplitFraction.usingUserDefaults(key: "bFraction")
    let bHide = SplitHide.usingUserDefaults(key: "bHide")
    let gFraction = SplitFraction.usingUserDefaults(key: "gFraction")
    let gHide = SplitHide.usingUserDefaults(key: "gHide")
    */
    let rFraction = SplitFraction()
    let rHide = SplitHide()
    let bFraction = SplitFraction()
    let bHide = SplitHide()
    let gFraction = SplitFraction()
    let gHide = SplitHide()
    @State private var demo: Int = 3
    
    var body: some View {
        VStack(spacing: 0) {
            Hiders(demo: $demo, rHide: rHide, bHide: bHide, gHide: gHide)
            if demo == 1 { // Simplest
                // Using ViewModifiers
                Color.green
                    .hSplit(fraction: gFraction, hide: gHide) { Color.yellow }
                /*
                // Using SplitView directly
                SplitView(
                    layout: .Horizontal,
                    fraction: gFraction,
                    hide: gHide,
                    primary: { Color.green },
                    secondary: { Color.yellow }
                )
                */
            } else if demo == 2 { // Mixed Horizontal and Vertical with List
                // Using ViewModifiers
                Color.green
                    .vSplit(fraction: gFraction, hide: gHide) { Color.yellow }
                    .hSplit(fraction: rFraction, hide: rHide) {
                        Color.blue
                            .hSplit(fraction: bFraction, hide: bHide) {
                                List { ForEach(["1", "2", "3", "4"], id:\.self) { item in
                                    Text(item)
                                }}
                            }
                    }
                /*
                // Using SplitView directly
                SplitView(
                    layout: .Horizontal,
                    fraction: rFraction,
                    hide: rHide,
                    primary: {
                        SplitView(
                            layout: .Vertical,
                            fraction: gFraction,
                            hide: gHide,
                            primary: { Color.green },
                            secondary: { Color.yellow }
                        )
                    },
                    secondary: {
                        SplitView(
                            layout: .Horizontal,
                            fraction: bFraction,
                            hide: bHide,
                            primary: { Color.blue },
                            secondary: {
                                List { ForEach(["1", "2", "3", "4"], id:\.self) { item in
                                    Text(item)
                                }}
                            }
                        )
                    }
                )
                */
            } else { // Mixed Horizontal and Vertical with only Colors
                // Using ViewModifiers
                Color.red
                    .hSplit(fraction: rFraction, hide: rHide) {
                        Color.blue
                            .vSplit(fraction: bFraction, hide: bHide) {
                                Color.green
                                    .hSplit(fraction: gFraction, hide: gHide) {
                                        Color.yellow
                                    }
                            }
                    }
                /*
                // Using SplitView directly
                SplitView(
                    layout: .Horizontal,
                    fraction: rFraction,
                    hide: rHide,
                    primary: { Color.red },
                    secondary: {
                        SplitView(
                            layout: .Vertical,
                            fraction: bFraction,
                            hide: bHide,
                            primary: { Color.blue },
                            secondary: {
                                SplitView(
                                    layout: .Horizontal,
                                    fraction: gFraction,
                                    hide: gHide,
                                    primary: { Color.green },
                                    secondary: { Color.yellow }
                                )
                            }
                        )
                    }
                )
                 */
            }
        }
    }
}

struct Hiders: View {
    // We observe rHide and friends here using ObservedObject and don't use StateObject
    // in ContentView because we want the buttons to be updated without creating an entirely
    // new ContentView. I'm doing some complex things in views that I'm splitting, so I
    // don't want them to be recreated every time I press a button to hide/show them.
    @Binding var demo: Int
    @ObservedObject var rHide: SplitHide
    @ObservedObject var bHide: SplitHide
    @ObservedObject var gHide: SplitHide
    
    var body: some View {
        HStack {
            Spacer()
            Button("Change Demo") {
                withAnimation {
                    demo = (demo + 1) % 3
                }
            }
            Spacer()
            Group {
                Button("Hide/Show") {
                    withAnimation {
                        rHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        bHide.toggle()
                    }
                }
                Button("Hide/Show") {
                    withAnimation {
                        gHide.toggle()
                    }
                }
            }
            Spacer()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
