//
//  ProgressTests.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import TooLegit
@testable import SoProgressive

class DescribeProgress: XCTestCase {

    func test_itHasSomeProperties() {
        let progress = Progress(kind: .Submitted, contextID: ContextID(id: "3232", context: .Course), itemType: .Assignment, itemID: "155")
        
        XCTAssertEqual(progress.contextID, ContextID(id: "3232", context: .Course))
        XCTAssertEqual(progress.kind, Progress.Kind.Submitted)
        XCTAssertEqual(progress.itemID, "155")
        XCTAssertEqual(progress.itemType, Progress.ItemType.Assignment)
    }

}
