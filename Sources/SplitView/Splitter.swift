//
//  Splitter.swift
//  SplitView
//
//  Created by Steven Harris on 8/18/21.
//

public protocol SplitDivider: View {
    var visibleThickness: CGFloat { get }
}

import SwiftUI

/// The Splitter that separates the `primary` from `secondary` views in a `Split` view.
public struct Splitter: SplitDivider {
    
    @EnvironmentObject private var layout: LayoutHolder
    @EnvironmentObject private var styling: SplitStyling
    private var color: Color { privateColor ?? styling.color }
    private var inset: CGFloat { privateInset ?? styling.inset }
    public var visibleThickness: CGFloat { privateVisibleThickness ?? styling.visibleThickness }
    private var invisibleThickness: CGFloat { privateInvisibleThickness ?? styling.invisibleThickness }
    private let privateColor: Color?
    private let privateInset: CGFloat?
    private let privateVisibleThickness: CGFloat?
    private let privateInvisibleThickness: CGFloat?
    
    // Defaults
    public static var defaultColor: Color = Color.gray
    public static var defaultInset: CGFloat = 6
    public static var defaultVisibleThickness: CGFloat = 4
    public static var defaultInvisibleThickness: CGFloat = 30

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
    
    public init(color: Color? = nil, inset: CGFloat? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil) {
        privateColor = color
        privateInset = inset
        privateVisibleThickness = visibleThickness
        privateInvisibleThickness = invisibleThickness
    }
    
}

struct Splitter_Previews: PreviewProvider {
    static var previews: some View {
        Splitter()
            .environmentObject(LayoutHolder(.horizontal))
            .environmentObject(SplitStyling())
        Splitter(color: Color.red, inset: 2, visibleThickness: 8, invisibleThickness: 30)
            .environmentObject(LayoutHolder(.horizontal))
            .environmentObject(SplitStyling())
        Splitter.line()
            .environmentObject(LayoutHolder(.horizontal))
            .environmentObject(SplitStyling())
        Splitter()
            .environmentObject(LayoutHolder(.vertical))
            .environmentObject(SplitStyling())
        Splitter(color: Color.red, inset: 2, visibleThickness: 8, invisibleThickness: 30)
            .environmentObject(LayoutHolder(.vertical))
            .environmentObject(SplitStyling())
        Splitter.line()
            .environmentObject(LayoutHolder(.vertical))
            .environmentObject(SplitStyling())
    }
}
