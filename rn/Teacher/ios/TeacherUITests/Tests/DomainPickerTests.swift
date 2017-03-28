//
//  DomainPickerTests.swift
//  Teacher
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import XCTest
import CanvasKeymaster

class DomainPickerTests: LogoutBeforeEach {
  
  func testDomainPicker_domainFieldAllowsInput() {
    let domain = "mobiledev"
    domainPickerPage.enterDomain(domain)
    domainPickerPage.assertDomainField(contains: domain)
  }
}
