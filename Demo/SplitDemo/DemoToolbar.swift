//
//  DemoToolbar.swift
//  Example
//
//  Created by Steven Harris on 2/10/23.
//

import SwiftUI
import SplitView

/// A toolbar that allows us to select the Demo to show and to display the AdjusterButtons for that
/// particular Demo. The AdjusterButtons allow us to adjust the `layout` and `hide` values if
/// the Demo specifies `holders`.
struct DemoToolbar: View {
    @Binding var demoID: DemoID
    
    var body: some View {
        let demo = demos[demoID]!
        HStack(alignment: .center, spacing: 8) {
            Text("Demo:")
            Menu(demo.label) {
                ForEach(DemoID.allCases, id: \.rawValue) { id in
                    Button(demos[id]!.label) {
                        withAnimation {
                            demoID = id
                        }
                    }
                }
            }
            Spacer()
            AdjusterButtons(demo: demo)
        }
        // The alignment between Menu and Buttons is whacky and
        // forced me to set frame and insets manually.
        .frame(height: 24)
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
    }
    
}

/// If the `demo` has `holders`, populate an HStack with sets of two buttons for each.
/// One of the buttons lets us hide/show the SplitSide, and the other lets us toggle the
/// `layout`.
struct AdjusterButtons: View {
    let demo: Demo
    
    var body: some View {
        let holders = demo.holders
        HStack {
            ForEach(holders) { holder in
                Divider()
                AdjustHideButton(layout: holder.layout, hide: holder.hide)
                AdjustLayoutButton(layout: holder.layout, hide: holder.hide)
            }
        }
    }
    
}

/// A button to toggle the SideHolder and to indicate the current state using the proper system image.
struct AdjustHideButton: View {
    @ObservedObject var layout: LayoutHolder
    @ObservedObject var hide: SideHolder
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    hide.toggle()
                }
            },
            label: {
                if hide.side == nil {
                    Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
                } else {
                    Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                }
            }
        )
    }
    
}

/// A button to toggle the LayoutHolder and to indicate the current state using the proper system image.
struct AdjustLayoutButton: View {
    @ObservedObject var layout: LayoutHolder
    @ObservedObject var hide: SideHolder
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    layout.toggle()
                }
            },
            label: {
                layout.isHorizontal ? Image(systemName: "rectangle.split.1x2") : Image(systemName: "rectangle.split.2x1")
            }
        )
        .disabled(hide.side != nil)
    }
    
}

struct DemoToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(DemoID.allCases, id: \.rawValue) { demoID in
            DemoToolbar(demoID: .constant(demoID))
        }
    }
}

