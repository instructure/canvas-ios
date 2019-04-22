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

import XCTest
@testable import Core

class RubricTests: XCTestCase {

    func testSelectedRating() {
        let a = RubricRating.make(["id": "a", "points": 1.0])
        let b = RubricRating.make(["id": "b", "points": 2.0])
        let c = RubricRating.make(["id": "c", "points": 3.0])

        let r = Rubric.make(["points": 2.0, "ratings": Set([a, b, c])] )

        let rating = r.selectedRating()

        XCTAssertEqual(rating, b)
    }
}
