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

class PageViewEventTests: XCTestCase {
    let date = Date(fromISOString: "2019-06-25T06:00:00Z")!

    func testStudentApiEvent() {
        let url = "https://localhost"
        let domain = "localhost"
        let context_type = "context_type"
        let appName = "Student"
        let real_user_id = "5"
        let user_id = "10"
        let session_id = "100"
        let agent = "agent"
        let customPageViewPath = "/custom"
        let props = [
            "url": url,
            "domain": domain,
            "context_type": context_type,
            "app_name": appName,
            "real_user_id": real_user_id,
            "user_id": user_id,
            "session_id": session_id,
            "agent": agent,
            "guid": "guid",
            "customPageViewPath": customPageViewPath,
        ]
        let e = PageViewEvent(eventName: "test", attributes: props, userID: "1", timestamp: date, eventDuration: 0.05)
        let tokenUrl = URL(string: "https://eventTokenUrl.localhost")!
        let authToken = "authToken"
        let props_token = "props_token"
        let expires_at = 1.0
        let token = APIPandataEventsToken(url: tokenUrl, auth_token: authToken, props_token: props_token, expires_at: expires_at)
        let event = e.apiEvent(
            token,
            appTag: "CANVAS_STUDENT_IOS"
        )
        XCTAssertEqual(event.eventType, APIPandataEventType.page_view)
        XCTAssertEqual(event.appTag, "CANVAS_STUDENT_IOS")
        XCTAssertEqual(event.timestamp, date)
        XCTAssertEqual(event.properties.agent, agent)
        XCTAssertEqual(event.properties.app_name, appName)
        XCTAssertEqual(event.properties.customPageViewPath, customPageViewPath)
        XCTAssertEqual(event.properties.domain, domain)
        XCTAssertEqual(event.properties.guid, e.guid)
        XCTAssertEqual(event.properties.interaction_seconds, 0.05)
        XCTAssertEqual(event.properties.page_name, "test")
        XCTAssertEqual(event.properties.real_user_id, real_user_id)
        XCTAssertEqual(event.properties.session_id, session_id)
        XCTAssertEqual(event.properties.url, url)
        XCTAssertEqual(event.properties.user_id, user_id)
    }

    func testTeacherApiEvent() {
        let url = "https://localhost"
        let domain = "localhost"
        let context_type = "context_type"
        let appName = "Teacher"
        let real_user_id = "5"
        let user_id = "10"
        let session_id = "100"
        let agent = "agent"
        let customPageViewPath = "/custom"
        let props = [
            "url": url,
            "domain": domain,
            "context_type": context_type,
            "app_name": appName,
            "real_user_id": real_user_id,
            "user_id": user_id,
            "session_id": session_id,
            "agent": agent,
            "guid": "guid",
            "customPageViewPath": customPageViewPath,
        ]
        let e = PageViewEvent(eventName: "test", attributes: props, userID: "1", timestamp: date, eventDuration: 0.05)
        let tokenUrl = URL(string: "https://eventTokenUrl.localhost")!
        let authToken = "authToken"
        let props_token = "props_token"
        let expires_at = 1.0
        let token = APIPandataEventsToken(url: tokenUrl, auth_token: authToken, props_token: props_token, expires_at: expires_at)
        let event = e.apiEvent(
            token,
            appTag: "CANVAS_TEACHER_IOS"
        )
        XCTAssertEqual(event.eventType, APIPandataEventType.page_view)
        XCTAssertEqual(event.appTag, "CANVAS_TEACHER_IOS")
        XCTAssertEqual(event.timestamp, date)
        XCTAssertEqual(event.properties.agent, agent)
        XCTAssertEqual(event.properties.app_name, appName)
        XCTAssertEqual(event.properties.customPageViewPath, customPageViewPath)
        XCTAssertEqual(event.properties.domain, domain)
        XCTAssertEqual(event.properties.guid, e.guid)
        XCTAssertEqual(event.properties.interaction_seconds, 0.05)
        XCTAssertEqual(event.properties.page_name, "test")
        XCTAssertEqual(event.properties.real_user_id, real_user_id)
        XCTAssertEqual(event.properties.session_id, session_id)
        XCTAssertEqual(event.properties.url, url)
        XCTAssertEqual(event.properties.user_id, user_id)
    }
}
