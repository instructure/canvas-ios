//
//  StudentTests.swift
//  StudentTests
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import XCTest
import EarlGrey
import SoSeedySwift
@testable import Student

class StudentTests: XCTestCase {
    func testGrpc_serverIsOnline() {
        let result = healthCheck()
        XCTAssertTrue(result.healthy)
    }
}
