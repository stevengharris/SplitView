//
//  Splitter.swift
//  SplitView
//
//  Created by Steven Harris on 8/18/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The Splitter that separates the primary from secondary views in a SplitView.
struct Splitter: View {
    
    private let orientation: Orientation
    private let color: Color
    private let inset: CGFloat
    private let visibleThickness: CGFloat
    private var invisibleThickness: CGFloat
    
    enum Orientation: CaseIterable {
        /// The orientation of the Splitter itself.
        /// Thus, use Horizontal in a VSplitView and Vertical in an HSplitView
        case Horizontal
        case Vertical
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            switch orientation {
            case .Horizontal:
                Color.clear
                    .frame(height: invisibleThickness)
                    .padding(0)
                RoundedRectangle(cornerRadius: visibleThickness / 2)
                    .fill(color)
                    .frame(height: visibleThickness)
                    .padding(EdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset))
            case .Vertical:
                Color.clear
                    .frame(width: invisibleThickness)
                    .padding(0)
                RoundedRectangle(cornerRadius: visibleThickness / 2)
                    .fill(color)
                    .frame(width: visibleThickness)
                    .padding(EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0))
            }
        }
        .contentShape(Rectangle())
        // Not happy with the behavior, so removing for now
        //.onHover { inside in
        //    if inside {
        //        orientation == .Horizontal ? NSCursor.resizeUpDown.push() : NSCursor.resizeLeftRight.push()
        //    } else {
        //        NSCursor.pop()
        //    }
        //}
    }
    
    init(orientation: Orientation, color: Color = Color.gray, inset: CGFloat = 8, visibleThickness: CGFloat, invisibleThickness: CGFloat) {
        self.orientation = orientation
        self.color = color
        self.inset = inset
        self.visibleThickness = visibleThickness
        self.invisibleThickness = invisibleThickness
    }
}


struct Splitter_Previews: PreviewProvider {
    static var previews: some View {
        Splitter(orientation: .Horizontal, visibleThickness: 4, invisibleThickness: 30)
        Splitter(orientation: .Vertical, visibleThickness: 4, invisibleThickness: 30)
    }
}
