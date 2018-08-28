//
// Copyright (C) 2018-present Instructure, Inc.
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
import XCTest
@testable import Core

class DatabaseOperationTest: CoreTestCase {
    func testItExecutesAndFinishes() {
        let operation = DatabaseOperation(database: database) { client in
            _ = Course.make(in: client)
            try client.save()
        }

        queue.addOperation(operation)
        queue.waitUntilAllOperationsAreFinished()

        let courses: [Course] = dbClient.fetch()
        XCTAssertEqual(courses.count, 1)
    }
}
