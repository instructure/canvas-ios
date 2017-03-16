//
//  Pages.swift
//  Teacher
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import XCTest
import EarlGrey
import SoGrey

extension XCTestCase {
  private struct Static {
    static let domainPickerPage = DomainPickerPage.self
  }
  
  var domainPickerPage: DomainPickerPage.Type { return Static.domainPickerPage }
}
