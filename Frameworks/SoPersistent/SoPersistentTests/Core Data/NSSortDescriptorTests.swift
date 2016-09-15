//
//  NSSortDescriptorTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoAutomated

class NSSortDescriptorTests: XCTestCase {

    func testAscending() {
        let sort = "name".ascending
        XCTAssert(sort.ascending)
        XCTAssertEqual("name", sort.key)
    }

    func testDescending() {
        let sort = "name".descending
        XCTAssertFalse(sort.ascending)
        XCTAssertEqual("name", sort.key)
    }

}
