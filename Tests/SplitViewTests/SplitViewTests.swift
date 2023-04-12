import XCTest
import SwiftUI
@testable import SplitView

struct ContentView: View {
    let hide = SideHolder()
    var body: some View {
        VStack(spacing: 0) {
            Button("Toggle Hide") {
                withAnimation {
                    hide.toggle()   // Toggle between hiding nothing and hiding secondary
                }
            }
            HSplit(left: { Color.red }, right: { Color.green })
                .hide(hide)
                .constraints(minPFraction: 0.2, minSFraction: 0.2)
                .splitter { Splitter.invisible() }
        }
    }
}

final class SplitViewTests: XCTestCase {
    func testSplitViewHideSecondary() {
        let view = ContentView()
        let hide = view.hide
        
        // Initial state: Both primary (red) and secondary (green) views are visible.
        XCTAssertNil(hide.side)
        
        // Toggle hide to hide the secondary (green) view.
        withAnimation {
            hide.toggle()
        }
        XCTAssertEqual(hide.side, .secondary)
        
        // Toggle hide again to unhide the secondary (green) view.
        withAnimation {
            hide.toggle()
        }
        XCTAssertNil(hide.side)
    }
    
    func testSplitViewHidPrimary() {
        let view = ContentView()
        let hide = view.hide
        
        // Initial state: Both primary (red) and secondary (green) views are visible.
        XCTAssertNil(hide.side)

        // Set the previous value to .primary (to simulate the initial old value)
        hide.side = .primary
        XCTAssertEqual(hide.side, .primary)

        // Toggle to unhide the primary side (red view).
        hide.toggle()
        XCTAssertNil(hide.side)

        // Toggle to hide the primary side again (red view).
        hide.toggle()
        XCTAssertEqual(hide.side, .primary)

        // Toggle to unhide the primary side again (red view).
        hide.toggle()
        XCTAssertNil(hide.side)
    }
}

