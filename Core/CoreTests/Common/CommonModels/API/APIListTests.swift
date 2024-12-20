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

import XCTest
@testable import Core

class APIListTests: XCTestCase {
    struct Mock: Codable, Equatable {
        let list: APIList<Int>
    }

    func testSingleValue() {
        let original = Mock(list: APIList(1))
        XCTAssertEqual(original, try JSONDecoder().decode(Mock.self, from: JSONEncoder().encode(original)))
    }

    func testArray() {
        let original = Mock(list: APIList(values: [ 2, 3, 4 ]))
        XCTAssertEqual(original, try JSONDecoder().decode(Mock.self, from: JSONEncoder().encode(original)))
    }
}
