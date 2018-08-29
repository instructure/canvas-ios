//
//  StudentTests.swift
//  StudentTests
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import XCTest
import EarlGrey
@testable import Student

class StudentTests: XCTestCase {

    func testSectionHeaders() {
        EarlGrey.selectElement(with: grey_text("Courses"))
            .assert(grey_notNil())

        EarlGrey.selectElement(with: grey_text("Groups"))
            .assert(grey_notNil())

        // Navigate to All Courses
        EarlGrey.selectElement(with: grey_accessibilityLabel("see_all_courses"))
            .assert(grey_notNil())
            .perform(grey_tap())

        EarlGrey.selectElement(with: grey_text("All Courses"))
            .assert(grey_notNil())

//        // Navigate back to Dashboard
//        EarlGrey.selectElement(with: grey_text("Back"))
//            .assert(grey_notNil())
//            .perform(grey_tap())
//
//        EarlGrey.selectElement(with: grey_text("Courses"))
//            .assert(grey_notNil())
    }
}
