//
//  DomainPickerTests.swift
//  Teacher
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import XCTest

class DomainPickerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  func testDomainPicker_domainFieldAllowsInput() {
    domainPickerPage.enterDomain("mobiledev")
    domainPickerPage.assertDomainField(contains: "mobiledev")
  }
  
}
