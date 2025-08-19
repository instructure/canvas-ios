//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import TestsFoundation
import XCTest
import Core

class SequenceExtensionsTests: XCTestCase {
    func testInterleaveEmpty() {
        XCTAssertEqual([].interleave(separator: 2), [])
    }

    func testInterleaveNonEmpty() {
        XCTAssertEqual("abcde".interleave(separator: ","), Array("a,b,c,d,e"))
    }

    func test_sortedByKeyPath() {
        let array: [Context] = [.account("3"),.user("1"),.course("2")]

        XCTAssertEqual(
            array.sorted(by: \.id).map(\.canvasContextID),
            ["user_1", "course_2", "account_3"]
        )

        XCTAssertEqual(
            array.sorted(by: \.canvasContextID).map(\.canvasContextID),
            ["account_3", "course_2", "user_1"]
        )
    }
}
