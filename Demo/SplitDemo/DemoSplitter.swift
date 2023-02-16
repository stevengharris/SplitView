//
//  DemoSplitter.swift
//  Example
//
//  Created by Steven Harris on 2/10/23.
//

import SwiftUI
import SplitView

/// A custom splitter for the `.customSplitter` demo.
///
/// Note a custom splitter must conform to SplitDivider protocol, which means it is a View that can tell the
/// SplitView what its `visibleThickness` is. The SplitView separates the `primary` and `secondary`
/// views by the `visibleThickness` of the SplitDivider.
///
/// A custom splitter should be sensitive to the layout, because if the layout changes, then the splitter needs to
/// change. Similarly, your splitter can react to changes in the SideHolder if needed. You can see an example
/// of these behaviors in DemoSplitter.
///
/// Like the default Splitter, the DemoSplitter uses a clear Color at the bottom of a ZStack to define what its
/// boundaries are, so that the drag gestures respond within this clear Color and the rectangle of the ZStack.
struct DemoSplitter: SplitDivider {
    var visibleThickness: CGFloat = 20
    @ObservedObject var layout: LayoutHolder
    @ObservedObject var hide: SideHolder
    let hideRight = Image(systemName: "arrowtriangle.right.square")
    let hideLeft = Image(systemName: "arrowtriangle.left.square")
    let hideDown = Image(systemName: "arrowtriangle.down.square")
    let hideUp = Image(systemName: "arrowtriangle.up.square")
    
    var body: some View {
        if layout.isHorizontal {
            ZStack {
                Color.clear
                    .frame(width: 30)
                    .padding(0)
                Button(
                    action: { withAnimation { hide.toggle() } },
                    label: {
                        hide.side == nil ? hideRight.imageScale(.large) : hideLeft.imageScale(.large)
                    }
                )
                .buttonStyle(.borderless)
            }
            .contentShape(Rectangle())
        } else {
            ZStack {
                Color.clear
                    .frame(height: 30)
                    .padding(0)
                Button(
                    action: { withAnimation { hide.toggle() } },
                    label: {
                        hide.side == nil ? hideDown.imageScale(.large) : hideUp.imageScale(.large)
                    }
                )
                .buttonStyle(.borderless)
            }
            .contentShape(Rectangle())
        }
    }
    
}

struct DemoSplitter_Previews: PreviewProvider {
    static var previews: some View {
        DemoSplitter(layout: LayoutHolder(.horizontal), hide: SideHolder())
        DemoSplitter(layout: LayoutHolder(.vertical), hide: SideHolder())
    }
}
