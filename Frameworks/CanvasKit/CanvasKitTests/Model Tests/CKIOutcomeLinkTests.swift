//
//  OutcomeLinkTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIOutcomeLinkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let outcomeLinkDictionary = Helpers.loadJSONFixture("outcome_link") as NSDictionary
        let outcomeLink = CKIOutcomeLink(fromJSONDictionary: outcomeLinkDictionary)
        
        XCTAssertEqual(outcomeLink.contextType!, "Account", "outcomeLink contextType did not parse correctly")
        XCTAssertEqual(outcomeLink.contextID!, "1", "outcomeLink contextID did not parse correctly")
        XCTAssertEqual(outcomeLink.url!, "/api/v1/account/1/outcome_groups/1/outcomes/1", "outcomeLink url did not parse correctly")
        XCTAssertEqual(outcomeLink.path!, "/api/v1/outcomes", "outcomeLink url did not parse correctly")
        XCTAssertNil(outcomeLink.outcome, "outcomeLink outcome did not parse correctly")
        XCTAssertNil(outcomeLink.outcomeGroup, "outcomeGroup details did not parse correctly")
    }
}
