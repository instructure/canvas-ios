//
//  LogoutBeforeEach.swift
//  Parent
//
//  Created by Brandon Pluim on 8/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import EarlGrey
import SoGrey
@testable import Parent

// Logs out before each test.
class LogoutBeforeEach: XCTestCase {

    override func setUp() {
        super.setUp()

        AppDelegate.resetApplicationForTesting()
    }
}
