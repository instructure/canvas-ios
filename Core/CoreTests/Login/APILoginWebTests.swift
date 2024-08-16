//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class APILoginWebTests: CoreTestCase {
    func testHeaders() {
        XCTAssertEqual(LoginWebRequest(authMethod: .normalLogin, clientID: "1", provider: nil).headers, [
            HttpHeader.userAgent: UserAgent.safari.description
        ])
        XCTAssertEqual(LoginWebRequest(authMethod: .siteAdminLogin, clientID: "1", provider: nil).headers, [
            HttpHeader.userAgent: UserAgent.safari.description,
            HttpHeader.cookie: "canvas_sa_delegated=1"
        ])
    }

    func testQuery() {
        XCTAssertEqual(LoginWebRequest(authMethod: .normalLogin, clientID: "1", provider: nil).query, [
            .value("client_id", "1"),
            .value("response_type", "code"),
            .value("redirect_uri", "https://canvas/login"),
            .value("mobile", "1")
        ])
        XCTAssertEqual(LoginWebRequest(authMethod: .canvasLogin, clientID: "1", provider: "p").query, [
            .value("client_id", "1"),
            .value("response_type", "code"),
            .value("redirect_uri", "https://canvas/login"),
            .value("mobile", "1"),
            .value("canvas_login", "1"),
            .value("authentication_provider", "p")
        ])
    }
}
