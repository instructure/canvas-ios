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
  var domainPickerPage: DomainPickerPage { return DomainPickerPage.sharedInstance }
  var canvasLoginPage: CanvasLoginPage { return CanvasLoginPage.sharedInstance }
  var courseBrowserPage: CourseListPage { return CourseListPage.sharedInstance }
}
