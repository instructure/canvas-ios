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

import Foundation
import XCTest
@testable import Core
@testable import Teacher

class KeychainTests: TeacherTestCase {
    func testSharedInstance() throws {
        let key = "foo"
        let str = "test"

        Keychain.shared.setData(str.data(using: .utf8)!, for: key)
        let data = try XCTUnwrap(Keychain.shared.getData(for: key))
        let value = String(data: data, encoding: .utf8)
        XCTAssertEqual(str, value)
    }
}
