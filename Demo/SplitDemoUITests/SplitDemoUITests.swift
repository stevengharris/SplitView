//
//  SplitDemoUITests.swift
//  SplitDemoUITests
//
//  Created by Cheuk Chau on 4/12/23.
//

import XCTest

final class SplitDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNavigation() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Locate the button using the accessibility identifier
        let demoM = app.popUpButtons[UIIdentifiers.demoMenu]
        XCTAssertTrue(demoM.exists)
        demoM.tap()
        
        // Select different modes
        let demoBsimpleAdj = app.menuItems[UIIdentifiers.demoButtonSimpleAdjustable]
        
        // Check if the button exists
        XCTAssertTrue(demoBsimpleAdj.exists)
        
        // Simulate a tap on the button
        demoBsimpleAdj.tap()
        
        let sahide = app.buttons[UIIdentifiers.smpAdjHHide]
        XCTAssertTrue(sahide.exists)
        sahide.tap()
        
        // Take screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "SimpleAdjustableLabel"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        /* if #available(macOS 10.15, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        } */
    }
}
