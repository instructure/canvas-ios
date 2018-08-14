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

    func testExample() {
      EarlGrey.selectElement(with: grey_text("Navigate"))
        .assert(grey_notNil())
    }
}
