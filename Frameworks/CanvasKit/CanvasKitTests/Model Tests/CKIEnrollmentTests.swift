//
//  CKIEnrollmentTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIEnrollmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let enrollmentDictionary = Helpers.loadJSONFixture("enrollment") as NSDictionary
        let enrollment = CKIEnrollment(fromJSONDictionary: enrollmentDictionary)

        XCTAssertEqual(enrollment.id!, "20179095", "Enrollment type was not parsed correctly")
        XCTAssertEqual(enrollment.role!, "designer", "Enrollment role was not parsed correctly")

        //I added these properties to enrollment.json even though the api doesn't appear to return them.
        //This is legacy code checking for these properties so it must have certain conditions where it returns these values
        XCTAssertEqual(enrollment.computedFinalScore!, 10, "Enrollment computedFinalScore was not parsed correctly")
        XCTAssertEqual(enrollment.computedCurrentScore!, 11, "Enrollment computedCurrentScore was not parsed correctly")
        XCTAssertEqual(enrollment.computedFinalGrade!, "A-", "Enrollment computedFinalGrade was not parsed correctly")
        XCTAssertEqual(enrollment.computedCurrentGrade!, "B+", "Enrollment computedCurrentGrade was not parsed correctly")
        XCTAssertFalse(enrollment.isStudent, "Enrollment isStudent was not parsed correctly")

    }
}
