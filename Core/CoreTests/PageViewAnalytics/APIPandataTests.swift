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

class APIPandataTests: XCTestCase {
    let token = APIPandataEventsToken(url: URL(string: "https://panda.data")!, auth_token: "t", props_token: "t", expires_at: Date().timeIntervalSince1970 + 1000)

    func testStudentPostPandataEventsTokenRequest() {
        let studentRequest = PostPandataEventsTokenRequest(appTag: "CANVAS_STUDENT_IOS")
        XCTAssertEqual(studentRequest.body?.app_key, "CANVAS_STUDENT_IOS")
    }

    func testTeacherPostPandataEventsTokenRequest() {
        let studentRequest = PostPandataEventsTokenRequest(appTag: "CANVAS_TEACHER_IOS")
        XCTAssertEqual(studentRequest.body?.app_key, "CANVAS_TEACHER_IOS")
    }

    func testPostPandataEventsRequest() {
        let events = [
            APIPandataEvent.pageView(timestamp: Date(), properties: APIPandataEventProperties(
                page_name: "page",
                url: nil,
                interaction_seconds: 0,
                domain: nil,
                context_type: nil,
                context_id: nil,
                app_name: nil,
                real_user_id: nil,
                user_id: nil,
                session_id: nil,
                agent: nil,
                guid: "g",
                customPageViewPath: nil
            ), signedProperties: token.props_token),
        ]
        let request = PostPandataEventsRequest(token: token, events: events)
        XCTAssertEqual(request.headers, [
            HttpHeader.authorization: "Bearer \(token.auth_token)",
        ])
        XCTAssertEqual(request.path, token.url.absoluteString)
        XCTAssertEqual(request.body?.events, events)
        XCTAssertEqual(try request.decode("hi".data(using: .utf8)!), "hi")
    }
}
