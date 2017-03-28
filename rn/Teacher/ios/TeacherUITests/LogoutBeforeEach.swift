//
//  LogoutBeforeEach.swift
//  Teacher
//
//  Created by Layne Moseley on 3/28/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import XCTest
import CanvasKeymaster

class LogoutBeforeEach: XCTestCase {
  
  override func setUp() {
    super.setUp()
    CanvasKeymaster.the().resetKeymasterForTesting()
  }
}
