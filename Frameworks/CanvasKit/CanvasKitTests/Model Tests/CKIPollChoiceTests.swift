//
//  CKIPollChoiceTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIPollChoiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pollChoiceDictionary = Helpers.loadJSONFixture("poll_choice") as NSDictionary
        let pollChoice = CKIPollChoice(fromJSONDictionary: pollChoiceDictionary)
        
        XCTAssertEqual(pollChoice.id!, "1023", "pollChoice id was not parsed correctly")
        XCTAssertTrue(pollChoice.isCorrect, "pollChoice isCorrect was not parsed correctly")
        XCTAssertEqual(pollChoice.text!, "Choice A", "pollChoice text was not parsed correctly")
        XCTAssertEqual(pollChoice.pollID!, 1779, "pollChoice pollID was not parsed correctly")
        XCTAssertEqual(pollChoice.index!, 1, "pollChoice index was not parsed correctly")
        XCTAssertEqual(CKIPollChoice.keyForJSONAPIContent()!, "poll_choices", "CKIPollChoice keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(pollChoice.path!, "/api/v1/poll_choices/1023", "pollChoice path was not parsed correctly")
    }
}
