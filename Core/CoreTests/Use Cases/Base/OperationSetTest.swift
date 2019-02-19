//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class OperationSetTest: CoreTestCase {
    func testItRunsOperations() {
        var count = 0
        let one = BlockOperation {
            count += 1
        }
        let two = BlockOperation {
            count += 1
        }
        let set = OperationSet(operations: [one, two])
        addOperationAndWait(set)
        XCTAssertEqual(count, 2)
    }

    func testAddSequence() {
        let one = BlockOperation {}
        let two = BlockOperation {}
        let three = BlockOperation {}
        let group = OperationSet()

        group.addSequence([one, two, three])

        XCTAssertEqual(one.dependencies.count, 0)
        XCTAssertEqual(two.dependencies.count, 1)
        XCTAssertEqual(two.dependencies.first, one)
        XCTAssertEqual(three.dependencies.count, 1)
        XCTAssertEqual(three.dependencies.first, two)
    }
}
