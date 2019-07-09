//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
