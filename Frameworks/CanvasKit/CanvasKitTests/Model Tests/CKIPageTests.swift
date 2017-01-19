//
//  CKIPageTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIPageTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pageDictionary = Helpers.loadJSONFixture("page") as NSDictionary
        let page = CKIPage(fromJSONDictionary: pageDictionary)
        
        XCTAssertEqual(page.title!, "My Page Title", "Page title did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2012-08-06T16:46:33-06:00")
        XCTAssertEqual(page.createdAt!, date, "Page createdAt did not parse correctly")
        
        date = formatter.dateFromString("2012-08-08T14:25:20-06:00")
        XCTAssertEqual(page.updatedAt!, date, "Page updatedAt did not parse correctly")
        XCTAssert(page.hideFromStudents, "Page hideFromStudents did not parse correctly")
        XCTAssertNotNil(page.lastEditedBy, "Page lastEditedBy did not parse correctly")
        XCTAssert(page.published, "Page published did not parse correctly")
        XCTAssert(page.frontPage, "Page frontPage did not parse correctly")
        XCTAssertEqual(page.path!, "/api/v1/pages/my-page-title", "Page path did not parse correctly")
    }
}
