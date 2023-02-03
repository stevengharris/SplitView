//
//  SplitView.swift
//  SplitView
//
//  Created by Steven Harris on 8/9/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// A View with a draggable `Splitter` between `primary` and `secondary`.
/// Views are layed out either horizontally or vertically as defined by `layout`.
public struct SplitView<P: View, S: View>: View {
    private let layout: SplitLayout
    private let visibleThickness: CGFloat
    private let invisibleThickness: CGFloat
    /// Only affects the initial layout, but updated to `privateFraction` after dragging ends.
    /// In this way, SplitView users can save the `SplitFraction` state to reflect slider position for restarts.
    @ObservedObject private var fraction: SplitFraction
    /// Use to hide/show `secondary` independent of dragging. When value is `false`, will restore to `privateFraction`.
    @ObservedObject private var hide: SplitHide
    /// The `primary` View, left when `layout==.Horizontal`, top when `layout==.Vertical`.
    private let primary: P
    /// The `secondary` View, right when `layout==.Horizontal`, bottom when `layout==.Vertical`.
    private let secondary: S
    /// The `Splitter` that sits between `primary` and `secondary`.
    private let splitter: Splitter
    /// Whether a `SplitFraction` was passed-in during `init`, to gate whether it is ever updated
    private let hasInitialFraction: Bool
    /// The key state that changes the split between `primary` and `secondary`
    @State private var privateFraction: CGFloat
    
    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let pLength = pLength(in: size)
            let sLength = sLength(in: size)
            let breadth = layout == .Horizontal ? size.height : size.width
            let pWidth = max(0, layout == .Horizontal ? min(size.width - visibleThickness, pLength - visibleThickness / 2) : breadth)
            let pHeight = max(0, layout == .Horizontal ? breadth : min(size.height - visibleThickness, pLength - visibleThickness / 2))
            let sWidth = max(0, layout == .Horizontal ? sLength - visibleThickness / 2 : breadth)
            let sHeight = max(0, layout == .Horizontal ? breadth : min(size.height - visibleThickness, sLength - visibleThickness / 2))
            let secondaryOffset = layout == .Horizontal ? CGSize(width: pWidth + visibleThickness, height: 0) : CGSize(width: 0, height: pHeight + visibleThickness)
            let splitPosition = layout == .Horizontal ? CGPoint(x: secondaryOffset.width - visibleThickness / 2, y: size.height / 2) : CGPoint(x: size.width / 2, y: secondaryOffset.height - visibleThickness / 2)
            ZStack(alignment: .topLeading) {
                primary
                    .frame(width: pWidth, height: pHeight)
                secondary
                    .frame(width: sWidth, height: sHeight)
                    .offset(secondaryOffset)
                splitter
                    .position(splitPosition)
                    .gesture(drag(in: size))
            }
            .clipped()
        }
    }
    
    public init(layout: SplitLayout? = nil, visibleThickness: CGFloat? = nil, invisibleThickness: CGFloat? = nil, fraction: SplitFraction? = nil, hide: SplitHide? = nil, @ViewBuilder primary: (()->P), @ViewBuilder secondary: (()->S)) {
        self.layout = layout ?? .Horizontal
        self.visibleThickness = visibleThickness ?? 4
        self.invisibleThickness = invisibleThickness ?? 30
        hasInitialFraction = fraction != nil
        self.fraction = fraction ?? SplitFraction()
        self.hide = hide ?? SplitHide()
        _privateFraction = State(initialValue: fraction?.value ?? 0.5)   // Local fraction updated during drag
        self.primary = primary()
        self.secondary = secondary()
        splitter = Splitter(layout: self.layout, visibleThickness: self.visibleThickness, invisibleThickness: self.invisibleThickness)
    }
    
    /// The Gesture recognized by the `Splitter`
    ///
    /// The main function of dragging is to modify the `privateFraction`, which is always between 0 and 1.
    /// Whenever we drag, we also set `hide.value` to nil. This is because the pLength and
    /// other dimensions key off of `hide` to return the full width/height when its value is non-nil
    /// When we are done dragging, we `updateSplitFraction`, which does nothing unless there was
    /// a `SplitFraction` passed-in at `init` time.
    private func drag(in size: CGSize) -> some Gesture {
        if layout == .Horizontal {
            return DragGesture()
                .onChanged { gesture in
                    hide.value = nil
                    privateFraction = min(1, max(0, gesture.location.x / size.width))
                }
                .onEnded { gesture in
                    updateSplitFraction(to: privateFraction)
                }
        } else {
            return DragGesture()
                .onChanged { gesture in
                    hide.value = nil
                    privateFraction = min(1, max(0, gesture.location.y / size.height))
                }
                .onEnded { gesture in
                    updateSplitFraction(to: privateFraction)
                }
        }
    }
    
    /// Set the SplitFraction.value only if it was passed-in at initialization time
    private func updateSplitFraction(to newFraction: CGFloat) {
        guard hasInitialFraction else { return }
        fraction.value = newFraction
    }
    
    /// The length of primary in the layout direction, without regard to any inset for the Splitter
    private func pLength(in size: CGSize) -> CGFloat {
        let length = layout == .Horizontal ? size.width : size.height
        guard let side = hide.value else {
            return length * privateFraction
        }
        return side == .Secondary ? length : 0
    }
    
    /// The length of secondary in the layout direction, without regard to any inset for the Splitter
    private func sLength(in size: CGSize) -> CGFloat {
        let length = layout == .Horizontal ? size.width : size.height
        guard let side = hide.value else {
            return length - pLength(in: size)
        }
        return side == .Primary ? length : 0
    }
    
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView(
            layout: .Horizontal,
            fraction: SplitFraction(0.75),
            primary: { Color.red },
            secondary: {
                SplitView(
                    layout: .Vertical,
                    primary: { Color.blue },
                    secondary: {
                        SplitView(
                            layout: .Vertical,
                            primary: { Color.green },
                            secondary: { Color.yellow }
                        )
                    }
                )
            }
        )
        .frame(width: 400, height: 400)
        SplitView(
            layout: .Horizontal,
            primary: { SplitView(layout: .Vertical, primary: { Color.red }, secondary: { Color.green }) },
            secondary: { SplitView(layout: .Horizontal, primary: { Color.blue }, secondary: { Color.yellow }) }
        )
        .frame(width: 400, height: 400)
    }
}

