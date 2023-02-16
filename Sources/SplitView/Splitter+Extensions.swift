//
//  Splitter+Extensions.swift
//  SplitView
//
//  This file is a place to hold generally useful extensions of Splitter. If you create one,
//  please add your name below to identify your extension, add it to this file, and submit
//  a pull request. Note that you should include a static function with both a LayoutHolder
//  and SplitLayout passed to it, so that people who want to be able to modify `layout` can
//  pass their LayoutHolder, not just the SplitLayout.
//
//  Created by Steven Harris on 2/16/23.
//
//  Extension authors:
//
//  Steven G. Harris created `line` and `invisible` extensions.
//

import SwiftUI

extension Splitter {
    
    /// A Splitter (that responds to changes in layout) that is a line across the full breadth of the view, by default gray and visibleThickness of 1
    public static func line(_ layout: LayoutHolder, color: Color? = nil, visibleThickness: CGFloat? = nil) -> Splitter {
        let config = SplitConfig(color: color, inset: 0, visibleThickness: visibleThickness ?? 1)
        return Splitter(layout, config: config)
    }

    /// A Splitter (with a fixed layout) that is a line across the full breadth of the view, by default gray and visibleThickness of 1
    public static func line(_ layout: SplitLayout, color: Color? = nil, visibleThickness: CGFloat? = nil) -> Splitter {
        line(LayoutHolder(layout), color: color, visibleThickness: visibleThickness)
    }
    
    /// An invisible Splitter (that responds to changes in layout) that is a line across the full breadth of the view
    public static func invisible(_ layout: LayoutHolder) -> Splitter {
        Splitter.line(layout, visibleThickness: 0)
    }

    /// An invisible Splitter (with a fixed layout) that is a line across the full breadth of the view
    public static func invisible(_ layout: SplitLayout) -> Splitter {
        Splitter.line(layout, visibleThickness: 0)
    }

}
