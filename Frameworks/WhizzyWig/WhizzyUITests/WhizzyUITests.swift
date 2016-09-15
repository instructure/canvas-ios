//
//  WhizzyUITests.swift
//  WhizzyUITests
//
//  Created by Derrick Hathaway on 6/10/15.
//
//

import Foundation
import XCTest

class WhizzyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()

        let table = app.tables.element
        table.swipeUp()
        table.staticTexts[" (Links to an external site.)"].tap()
    }
}
