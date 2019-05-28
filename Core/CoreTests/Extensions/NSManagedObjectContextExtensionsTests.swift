//
// Copyright (C) 2019-present Instructure, Inc.
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
@testable import Core
import XCTest

class NSManagedObjectContextExtensionsTests: CoreTestCase {
    func testAll() {
        let yes = Course.make(from: .make(id: "1"))
        let yess = Course.make(from: .make(id: "1"))
        let no = Course.make(from: .make(id: "2"))
        let results: [Course] = databaseClient.all(where: #keyPath(Course.id), equals: "1")
        XCTAssertTrue(results.contains(yes))
        XCTAssertTrue(results.contains(yess))
        XCTAssertFalse(results.contains(no))
    }

    func testFirst() {
        let yes = Course.make(from: .make(id: "1"))
        let yess = Course.make(from: .make(id: "1"))
        let no = Course.make(from: .make(id: "2"))
        guard let result: Course = databaseClient.first(where: #keyPath(Course.id), equals: "1") else {
            XCTFail()
            return
        }
        XCTAssertTrue(result == yes || result == yess)
        XCTAssertFalse(result == no)

    }
}
