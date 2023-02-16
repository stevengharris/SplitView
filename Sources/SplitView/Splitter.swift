//
//  Splitter.swift
//  SplitView
//
//  Created by Steven Harris on 8/18/21.
//

import SwiftUI

public protocol SplitDivider: View {
    var visibleThickness: CGFloat { get }
}

/// The Splitter that separates the `primary` from `secondary` views in a `SplitView`.
public struct Splitter: SplitDivider {
    
    @ObservedObject private var layout: LayoutHolder
    private let config: SplitConfig
    private var color: Color { config.color }
    private var inset: CGFloat { config.inset }
    public var visibleThickness: CGFloat { config.visibleThickness }
    private var invisibleThickness: CGFloat { config.invisibleThickness }
    
    // Defaults
    public static var defaultColor: Color = Color.gray
    public static var defaultInset: CGFloat = 6
    public static var defaultVisibleThickness: CGFloat = 4
    public static var defaultInvisibleThickness: CGFloat = 30
    
    // Default .horizontal and .vertical Splitters
    public static var horizontal: Splitter = Splitter(.horizontal)
    public static var vertical: Splitter = Splitter(.vertical)
    
    public var body: some View {
        ZStack {
            switch layout.value {
            case .horizontal:
                Color.clear
                    .frame(width: invisibleThickness)
                    .padding(0)
                RoundedRectangle(cornerRadius: visibleThickness / 2)
                    .fill(color)
                    .frame(width: visibleThickness)
                    .padding(EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0))
            case .vertical:
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
                layout.isHorizontal ? NSCursor.resizeLeftRight.push() : NSCursor.resizeUpDown.push()
            } else {
                NSCursor.pop()
            }
            #endif
        }
        */
    }
    
    public init(_ layout: LayoutHolder, config: SplitConfig? = nil) {
        self.layout = layout
        self.config = config ?? SplitConfig()
    }
    
    public init(_ layout: SplitLayout, config: SplitConfig? = nil) {
        self.init(LayoutHolder(layout), config: config)
    }
    
}


struct Splitter_Previews: PreviewProvider {
    static var previews: some View {
        Splitter.horizontal
        Splitter.vertical
    }
}
