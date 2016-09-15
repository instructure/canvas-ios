//
//  MediaUITests.swift
//  MediaUITests
//
//  Created by Derrick Hathaway on 11/12/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import XCTest

extension XCTestCase {
    func waitForElement(element: XCUIElement, timeout: NSTimeInterval = 5) -> XCUIElement {
        let exists = NSPredicate(format: "exists == true")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(timeout, handler: nil)
        
        return element
    }
    
}

extension XCUIElement /*TapAtPosition*/ {
    func tapAtPosition(let position: CGPoint) {
        let cooridnate = self.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 0)).coordinateWithOffset(CGVector(dx: position.x, dy: position.y))
        cooridnate.tap()
    }
}

class AudioRecorderUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRecordStopPlayPauseTrash() {
        let app = XCUIApplication()
        app.tables.staticTexts["Record Audio Test"].tap()
        
        let record = waitForElement(app.buttons["Record"])
        record.tap()
        
        // do a 2 second recording
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))
        
        let stop = waitForElement(app.buttons["Stop"])
        stop.tap()
        
        let play = waitForElement(app.buttons["Play"])
        play.tap()
        
        let pause = waitForElement(app.buttons["Pause"])
        pause.tap()
        
        let trash = waitForElement(app.buttons["Trash"])
        trash.tap()
        
        let sheet = app.sheets["Delete recording?"]
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            sheet.tapAtPosition(CGPoint(x: 0.0, y: -100.0))
        } else {
            let cancelDelete = waitForElement(sheet.buttons["Cancel"])
            cancelDelete.tap()
        }
        
        
        // trash it again
        waitForElement(trash).tap()
        
        let deleteButton = waitForElement(sheet.buttons["Delete"])
        deleteButton.tap()
        
        waitForElement(app.buttons["Record"])
        
        let cancelRecording = waitForElement(app.buttons["Cancel"])
        cancelRecording.tap()
        
        waitForElement(app.staticTexts["No worries, Mate."])
        let rightOh = waitForElement(app.buttons["Crikey!"])
        rightOh.tap()
    }
    
    func testCompleteRecording() {
        let app = XCUIApplication()
        app.tables.staticTexts["Record Audio Test"].tap()
        
        let record = waitForElement(app.buttons["Record"])
        record.tap()
        
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))

        let stop = waitForElement(app.buttons["Stop"])
        stop.tap()
        
        let done = waitForElement(app.buttons["So Done!"])
        done.tap()
        
        waitForElement(app.staticTexts["Good on ya, Mate!"])
        let right = waitForElement(app.buttons["Right!"])
        right.tap()
    }
    
    func testCancelWithAudioRecordedPromptsToDelete() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Record Audio Test"].tap()
        
        let record = waitForElement(app.buttons["Record"])
        record.tap()
        
        // do a 2 second recording
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))
        
        let cancel = waitForElement(app.buttons["Cancel"])
        cancel.tap()
        
        
        let sheet = waitForElement(app.sheets["Delete recording?"])
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            sheet.tapAtPosition(CGPoint(x: 0.0, y: -100.0))
        } else {
            let cancelDelete = waitForElement(sheet.buttons["Cancel"])
            cancelDelete.tap()
        }
        
        cancel.tap()
        let delete = waitForElement(sheet.buttons["Delete"])
        delete.tap()
        
        waitForElement(app.staticTexts["No worries, Mate."])
    }
    
    // MARK: Denied!
    
    func testUserHasDeniedRecorderAccess() {
        
        let app = XCUIApplication()
        waitForElement(app.tables.staticTexts["Record Permission Denied"]).tap()
        waitForElement(app.buttons["Request Audio Recording Permission"]).tap()
        waitForElement(app.buttons["Record Permission Help"]).tap()
        waitForElement(app.alerts["Not Permitted"].collectionViews.buttons["Dismiss"]).tap()
        waitForElement(app.buttons["Cancel"]).tap()
        
        waitForElement(app.alerts["No worries, Mate."].collectionViews.buttons["Crikey!"]).tap()
    }
    
    func testRequestPermissionSucceeds() {
        
        let app = XCUIApplication()
        waitForElement(app.tables.staticTexts["Request Recording Permission"]).tap()
        waitForElement(app.buttons["Request Audio Recording Permission"]).tap()
        waitForElement(app.buttons["Record"]).tap()
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(2))
        waitForElement(app.buttons["Stop"]).tap()
        waitForElement(app.buttons["So Done!"]).tap()
        waitForElement(app.alerts["Good on ya, Mate!"].collectionViews.buttons["Right!"]).tap()
    }
}
