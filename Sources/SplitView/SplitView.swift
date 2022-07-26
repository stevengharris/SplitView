//
//  SplitView.swift
//  SplitView
//
//  Created by Steven Harris on 8/9/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// A view containing a primary view and a secondary view layed-out vertically and separated by a draggable horizontally-oriented Splitter
///
/// The primary view is above the secondary view.
struct VSplitView<P: View, S: View>: View {
    private let zIndex: Double
    private let visibleThickness: CGFloat
    private let invisibleThickness: CGFloat
    @Binding private var fraction: CGFloat
    @Binding private var secondaryHidden: Bool
    private let primary: ()->P
    private let secondary: ()->S
    
    var body: some View {
        SplitView(
            layout: .Vertical,
            zIndex: zIndex,
            visibleThickness: visibleThickness,
            invisibleThickness: invisibleThickness,
            fraction: $fraction,
            secondaryHidden: $secondaryHidden,
            primary: primary,
            secondary: secondary)
    }
    
    init(
        zIndex: Double = 0,
        visibleThickness: CGFloat = 4,
        invisibleThickness: CGFloat = 30,
        fraction: Binding<CGFloat> = .constant(0.5),
        secondaryHidden: Binding<Bool>? = nil,
        @ViewBuilder primary: @escaping (()->P),
        @ViewBuilder secondary: @escaping (()->S)) {
        self.zIndex = zIndex
        self.visibleThickness = visibleThickness
        self.invisibleThickness = invisibleThickness
        _fraction = fraction
        _secondaryHidden = secondaryHidden ?? .constant(false)
        self.primary = primary
        self.secondary = secondary
    }
    
}


/// A view containing a primary view and a secondary view layed-out horizontally and separated by a draggable vertically-oriented Splitter
///
/// The primary view is to the left of the secondary view.
struct HSplitView<P: View, S: View>: View {
    private let zIndex: Double
    private let visibleThickness: CGFloat
    private let invisibleThickness: CGFloat
    @Binding private var fraction: CGFloat
    @Binding private var secondaryHidden: Bool
    private let primary: ()->P
    private let secondary: ()->S
    
    var body: some View {
        SplitView(
            layout: .Horizontal,
            zIndex: zIndex,
            visibleThickness: visibleThickness,
            invisibleThickness: invisibleThickness,
            fraction: $fraction,
            secondaryHidden: $secondaryHidden,
            primary: primary,
            secondary: secondary)
    }
    
    init(
        zIndex: Double = 0,
        visibleThickness: CGFloat = 4,
        invisibleThickness: CGFloat = 30,
        fraction: Binding<CGFloat> = .constant(0.5),
        secondaryHidden: Binding<Bool>? = nil,
        @ViewBuilder primary: @escaping (()->P),
        @ViewBuilder secondary: @escaping (()->S)) {
        self.zIndex = zIndex
        self.visibleThickness = visibleThickness
        self.invisibleThickness = invisibleThickness
        _fraction = fraction
        _secondaryHidden = secondaryHidden ?? .constant(false)
        self.primary = primary
        self.secondary = secondary
    }
    
}

/// The SplitView that is instantiated publicly using either a VSplitView or HSplitView.
///
/// The zIndex is needed for SplitViews that contain SplitViews sometimes, because the overlap of the multiple
/// Splitters with the primary/secondary of adjacent views prevents the drag gesture from being detected.
/// For example, in the following example, the various zIndexes keep the major vertical splitter on top, while the
/// horizontal splitter overlays the green-yellow, and the smaller vertical splitter is underneath it. The full
/// "invisibleWidth" of the splitter is then responsive for all three, modulo the overlaps at the ends. For example:
/// ```
///     HSplitView(
///         zIndex: 2,
///         fraction: .constant(0.5),
///         primary: { Color.red },
///         secondary: {
///             VSplitView(
///                 zIndex: 1,
///                 fraction: .constant(0.5),
///                 primary: { Color.blue },
///                 secondary: {
///                     HSplitView(
///                         zIndex: 0,
///                         fraction: .constant(0.5),
///                         primary: { Color.green },
///                         secondary: { Color.yellow }
///                     )
///                 }
///             )
///         }
///     )
///```
///The zIndex is not needed in simpler cases.
fileprivate struct SplitView<P: View, S: View>: View {
    private let layout: Layout
    private let zIndex: Double
    private let visibleThickness: CGFloat
    private let invisibleThickness: CGFloat
    @Binding private var initialFraction: CGFloat
    @Binding private var secondaryHidden: Bool
    private let primary: P
    private let secondary: S
    @State private var privateFraction: CGFloat
    @State private var overallSize: CGSize = .zero
    @State private var primaryWidth: CGFloat?
    @State private var primaryHeight: CGFloat?
    
    let sizingQueue = DispatchQueue(label: "SizePreference", qos: .userInteractive)

    var hDrag: some Gesture {
        // As we drag the Splitter horizontally, adjust the primaryWidth and recalculate fraction
        DragGesture()
            .onChanged { gesture in
                let x = min(max(gesture.location.x, 0), overallSize.width)
                primaryWidth = x
                privateFraction = x / overallSize.width
            }
            .onEnded { gesture in
                primaryWidth = nil                  // So that secondaryHidden works after drag
                initialFraction = privateFraction   // To hold in UserData
            }
    }
    
    var vDrag: some Gesture {
        // As we drag the Splitter vertically, adjust the primaryHeight and recalculate fraction
        DragGesture()
            .onChanged { gesture in
                let y = min(max(gesture.location.y, 0), overallSize.height)
                primaryHeight = y
                privateFraction = y / overallSize.height
            }
            .onEnded { gesture in
                primaryHeight = nil                 // So that secondaryHidden works after drag
                initialFraction = privateFraction   // To hold in UserData
            }
    }
    
    enum Layout: CaseIterable {
        /// The orientation of the primary and seconday views (e.g., Vertical = VStack, Horizontal = HStack)
        case Horizontal
        case Vertical
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            switch layout {
            case .Horizontal:
                // When we init the view, primaryWidth is nil, so we calculate it from the
                // fraction that was passed-in. This lets us specify the location of the Splitter
                // when we instantiate the SplitView.
                Group {
                    primary
                        .frame(width: pWidth())
                    secondary
                        .frame(width: sWidth())
                        .clipped() // Must be present before offset to prevent ListHeader above List from extending beyond VStack!
                        .offset(x: offsetWidth(), y: 0)
                    Splitter(orientation: .Vertical, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness)
                        .frame(width: invisibleThickness, height: overallSize.height)
                        .position(x: pWidth() + visibleThickness / 2, y: overallSize.height / 2)
                        .zIndex(zIndex)
                        .gesture(hDrag, including: .all)
                }
            case .Vertical:
                // When we init the view, primaryHeight is nil, so we calculate it from the
                // fraction that was passed-in. This lets us specify the location of the Splitter
                // when we instantiate the SplitView.
                Group {
                    primary
                        .frame(height: pHeight())
                    secondary
                        .frame(height: sHeight())
                        .clipped() // Must be present before offset to prevent ListHeader above List from extending beyond VStack!
                        .offset(x: 0, y: offsetHeight())
                    Splitter(orientation: .Horizontal, visibleThickness: visibleThickness, invisibleThickness: invisibleThickness)
                        .frame(width: overallSize.width, height: invisibleThickness)
                        .position(x: overallSize.width / 2, y: pHeight() + visibleThickness / 2)
                        .zIndex(zIndex)
                        .gesture(vDrag, including: .all)
                }
            }
        }
        .background(GeometryReader { geometry in
            // Track the overallSize using a GeometryReader on a clear background on the ZStack contains the
            // primary, secondary, and splitter
            Color.clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
                .onPreferenceChange(SizePreferenceKey.self) { newSize in
                    // Run async to avoid "Bound preference SizePreferenceKey tried to update multiple times per frame"
                    sizingQueue.async {
                        overallSize = newSize
                    }
                }
        })
        .contentShape(Rectangle())
    }
    
    init(layout: Layout, zIndex: Double, visibleThickness: CGFloat, invisibleThickness: CGFloat, fraction: Binding<CGFloat>, secondaryHidden: Binding<Bool>, @ViewBuilder primary: (()->P), @ViewBuilder secondary: (()->S)) {
        self.layout = layout
        self.zIndex = zIndex
        self.visibleThickness = visibleThickness
        self.invisibleThickness = invisibleThickness
        _initialFraction = fraction                                     // Binding, update when drag ends
        _privateFraction = State(initialValue: fraction.wrappedValue)   // Local fraction updated during drag
        _primaryWidth = State(initialValue: nil)
        _primaryHeight = State(initialValue: nil)
        _secondaryHidden = secondaryHidden
        self.primary = primary()
        self.secondary = secondary()
    }
    
    private func pWidth() -> CGFloat {
        // Return the width of the primary view when .Horizontal or primaryWidth if not nil
        guard primaryWidth == nil else { return primaryWidth! }
        var pWidth: CGFloat
        if secondaryHidden {
            pWidth = overallSize.width - visibleThickness / 2
        } else {
            pWidth = (overallSize.width * privateFraction) - (visibleThickness / 2)
        }
        return min(max(0, pWidth), overallSize.width)
    }
    
    private func sWidth() -> CGFloat {
        return max(0, overallSize.width - pWidth() - visibleThickness)
    }
    
    private func offsetWidth() -> CGFloat {
        // Return the offset to the secondary view when .Horizontal
        if secondaryHidden {
            return overallSize.width
        } else {
            return (overallSize.width * privateFraction) + visibleThickness / 2
        }
    }
    
    private func pHeight() -> CGFloat {
        // Return the height of the primary view when .Vertical or primaryHeight if not nil
        guard primaryHeight == nil else { return primaryHeight! }
        var pHeight: CGFloat
        if secondaryHidden {
            pHeight = overallSize.height - visibleThickness / 2
        } else {
            pHeight = (overallSize.height * privateFraction) - (visibleThickness / 2)
        }
        return min(max(0, pHeight), overallSize.height)
    }
    
    private func sHeight() -> CGFloat {
        return max(0, overallSize.height - pHeight() - visibleThickness)
    }
    
    private func offsetHeight() -> CGFloat {
        // Return the offset to the secondary view when .Vertical
        if secondaryHidden {
            return overallSize.height
        } else {
            return (overallSize.height * privateFraction) + visibleThickness / 2
        }
    }
    
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SplitView_Previews: PreviewProvider {
    static var previews: some View {
        HSplitView(
            zIndex: 2,
            fraction: .constant(0.75),
            primary: { Color.red },
            secondary: {
                VSplitView(
                    zIndex: 1,
                    primary: { Color.blue },
                    secondary: {
                        VSplitView(
                            zIndex: 0,
                            primary: { Color.green },
                            secondary: { Color.yellow }
                        )
                    }
                )
            }
        )
        .frame(width: 400, height: 400)
        HSplitView(
            primary: { VSplitView( primary: { Color.red }, secondary: { Color.green }) },
            secondary: { HSplitView( primary: { Color.blue }, secondary: { Color.yellow }) }
        )
        .frame(width: 400, height: 400)
    }
}

