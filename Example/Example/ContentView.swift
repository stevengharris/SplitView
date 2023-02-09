//
//  ContentView.swift
//  Example
//
//  Created by Steven Harris on 2/4/23.
//

import SwiftUI
import SplitView

struct ContentView: View {
    /*
    // Use the following to get/set from UserDefaults.standard
    let rFraction = FractionHolder.usingUserDefaults(key: "rFraction")
    let rHide = SideHolder.usingUserDefaults(key: "rHide")
    let bFraction = FractionHolder.usingUserDefaults(key: "bFraction")
    let bHide = SideHolder.usingUserDefaults(key: "bHide")
    let gFraction = FractionHolder.usingUserDefaults(key: "gFraction")
    let gHide = SideHolder.usingUserDefaults(key: "gHide")
    */
    let rFraction = FractionHolder()
    let rHide = SideHolder()
    let bFraction = FractionHolder()
    let bHide = SideHolder()
    let gFraction = FractionHolder()
    let gHide = SideHolder()
    @State private var demo: Int = 1

    var body: some View {
        VStack(spacing: 0) {
            Hiders(demo: $demo, rHide: rHide, bHide: bHide, gHide: gHide)
            if demo == 1 { // Simplest
                Color.green
                    .split(.Horizontal, fraction: gFraction, hide: gHide) { Color.yellow }
            } else if demo == 2 { // Mixed Horizontal and Vertical with List
                Color.red
                    .split(.Vertical, fraction: rFraction, hide: rHide) { Color.blue }
                    .split(.Horizontal, fraction: gFraction, hide: gHide) {
                        Color.green
                            .split(.Horizontal, fraction: gFraction, hide: gHide) {
                                List { ForEach(["1", "2", "3", "4"], id:\.self) { item in
                                    Text(item)
                                }}
                            }
                    }
            } else if demo == 3 { // Mixed Horizontal and Vertical with only Colors
                Color.red
                    .split(.Horizontal, fraction: rFraction, hide: rHide) {
                        Color.blue
                            .split(.Vertical, fraction: bFraction, hide: bHide) {
                                Color.green
                                    .split(.Horizontal, fraction: gFraction, hide: gHide) {
                                        Color.yellow
                                    }
                            }
                    }
            } else {    // Every variation of the .split modifier
                VStack {
                    Group {
                        // Using default Splitter
                        Color.red.split(.Horizontal) { Color.green }
                        Color.red.split(.Horizontal, hide: .Secondary) { Color.green }
                        Color.red.split(.Horizontal, fraction: 0.25) { Color.green }
                        Color.red.split(.Horizontal, fraction: 0.25, hide: .Secondary) { Color.green }
                        Color.red.split(.Horizontal, hide: gHide) { Color.green }
                        Color.red.split(.Horizontal, fraction: gFraction) { Color.green }
                        Color.red.split(.Horizontal, fraction: gFraction, hide: gHide) { Color.green }
                    }
                    //Group {
                    //    // Using custom Splitter
                    //    Color.red.split(.Horizontal, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, hide: .Secondary, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, fraction: 0.25, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, fraction: 0.25, hide: .Secondary, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, hide: gHide, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, fraction: gFraction, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //    Color.red.split(.Horizontal, fraction: gFraction, hide: gHide, splitter: { Splitter(.Horizontal, color: .black) }) { Color.green }
                    //}
                }
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
    @ObservedObject var rHide: SideHolder
    @ObservedObject var bHide: SideHolder
    @ObservedObject var gHide: SideHolder
    
    var body: some View {
        HStack {
            Spacer()
            Button("Change Demo") {
                withAnimation {
                    demo = (demo + 1) % 4
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

