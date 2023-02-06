//
//  Splitter.swift
//  SplitView
//
//  Created by Steven Harris on 8/18/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The Splitter that separates the `primary` from `secondary` views in a `SplitView`.
public struct Splitter: View {
    
    private let layout: SplitLayout
    private let color: Color
    private let inset: CGFloat
    private let visibleThickness: CGFloat
    private var invisibleThickness: CGFloat
    
    public static var horizontal: Splitter {
        Splitter(layout: .Horizontal, visibleThickness: 4, invisibleThickness: 30)
    }
    
    public static var vertical: Splitter {
        Splitter(layout: .Vertical, visibleThickness: 4, invisibleThickness: 30)
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            switch layout {
            case .Horizontal:
                Color.clear
                    .frame(width: invisibleThickness)
                    .padding(0)
                RoundedRectangle(cornerRadius: visibleThickness / 2)
                    .fill(color)
                    .frame(width: visibleThickness)
                    .padding(EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0))
            case .Vertical:
                Color.clear
                    .frame(height: invisibleThickness)
                    .padding(0)
                RoundedRectangle(cornerRadius: visibleThickness / 2)
                    .fill(color)
                    .frame(height: visibleThickness)
                    .padding(EdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset))
            }
        }
        .contentShape(Rectangle())
        /*
         TODO: This seems to work okay in simple situations, but is kinda janky in others, so removing for now
        .onHover { inside in
            // Perhaps should consider some kind of custom hoverEffect, since the cursor change
            // doesn't work on iOS
            #if targetEnvironment(macCatalyst)
            if inside {
                layout == .Horizontal ? NSCursor.resizeLeftRight.push() : NSCursor.resizeUpDown.push()
            } else {
                NSCursor.pop()
            }
            #endif
        }
        */
    }
    
    public init(layout: SplitLayout, color: Color = Color.gray, inset: CGFloat = 8, visibleThickness: CGFloat, invisibleThickness: CGFloat) {
        self.layout = layout
        self.color = color
        self.inset = inset
        self.visibleThickness = visibleThickness
        self.invisibleThickness = invisibleThickness
    }
    
}


struct Splitter_Previews: PreviewProvider {
    static var previews: some View {
        Splitter(layout: .Horizontal, visibleThickness: 4, invisibleThickness: 30)
        Splitter(layout: .Vertical, visibleThickness: 4, invisibleThickness: 30)
    }
}
