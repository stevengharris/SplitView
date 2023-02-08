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
    
    public static var defaultColor: Color = Color.gray
    public static var defaultInset: CGFloat = 8
    public static var defaultVisibleThickness: CGFloat = 4
    public static var defaultInvisibleThickness: CGFloat = 30
    public static var horizontal: Splitter { Splitter(.Horizontal) }
    public static var vertical: Splitter { Splitter(.Vertical) }
    
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
    
    public init(_ layout: SplitLayout, color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) {
        self.layout = layout
        self.color = color ?? Self.defaultColor
        self.inset = inset ?? Self.defaultInset
        self.visibleThickness = visibleThickness ?? Self.defaultVisibleThickness
        self.invisibleThickness = invisibleThickness ?? Self.defaultInvisibleThickness
    }
    
}


struct Splitter_Previews: PreviewProvider {
    static var previews: some View {
        Splitter.horizontal
        Splitter.vertical
    }
}
