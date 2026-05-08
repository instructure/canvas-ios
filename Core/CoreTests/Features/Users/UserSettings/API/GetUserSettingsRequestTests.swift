//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

final class GetUserSettingsRequestTests: XCTestCase {

    func test_path() {
        let request = GetUserSettingsRequest(userID: "some-user-id")
        XCTAssertEqual(request.path, "users/some-user-id/settings")
    }

    func test_method() {
        let request = GetUserSettingsRequest(userID: "some-user-id")
        XCTAssertEqual(request.method, .get)
    }

    func test_query_shouldIncludeMobileSettings() {
        let request = GetUserSettingsRequest(userID: "some-user-id")
        XCTAssertEqual(request.query, [.include(["mobile_settings"])])
    }
}
