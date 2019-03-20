//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core
import XCTest

class NSManagedObjectContextExtensionsTests: CoreTestCase {
    func testAll() {
        let yes = Course.make(["id": "1"])
        let yess = Course.make(["id": "1"])
        let no = Course.make(["id": "2"])
        let results: [Course] = databaseClient.all(where: #keyPath(Course.id), equals: "1")
        XCTAssertTrue(results.contains(yes))
        XCTAssertTrue(results.contains(yess))
        XCTAssertFalse(results.contains(no))
    }

    func testFirst() {
        let yes = Course.make(["id": "1"])
        let yess = Course.make(["id": "1"])
        let no = Course.make(["id": "2"])
        guard let result: Course = databaseClient.first(where: #keyPath(Course.id), equals: "1") else {
            XCTFail()
            return
        }
        XCTAssertTrue(result == yes || result == yess)
        XCTAssertFalse(result == no)

    }
}
