//
//  CKISectionTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKISectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let sectionDictionary = Helpers.loadJSONFixture("section") as NSDictionary
        let section = CKISection(fromJSONDictionary: sectionDictionary)

        XCTAssertEqual(section.id!, "1", "section id not parsed correctly")
        XCTAssertEqual(section.name!, "Section A", "section name not parsed correctly")
        XCTAssertEqual(section.courseID!, "7", "section courseID not parsed correctly")
        XCTAssertEqual(section.path!, "/api/v1/sections/1", "section path not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
