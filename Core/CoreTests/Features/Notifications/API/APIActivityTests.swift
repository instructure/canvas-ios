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

class APIActivityTests: XCTestCase {
    let mockNow = Date(fromISOString: "2019-11-20T06:00:00Z")!
    let mockYesterday = Date(fromISOString: "2019-11-20T06:00:00Z")! - .day

    func testGetActivitiesRequest() {
        let request = GetActivitiesRequest()
        XCTAssertEqual(request.path, "users/self/activity_stream")
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "only_active_courses", value: "true")])
        XCTAssertEqual(GetActivitiesRequest(perPage: 100).queryItems[1], URLQueryItem(name: "per_page", value: "100"))
    }

    func testConversationDeletedOneDayAfterHasLastMessage() {
        let activity = APIActivity.make(
            updated_at: mockNow,
            type: .conversation,
            latest_messages: [.make(
                created_at: mockYesterday
            )]
        )

        XCTAssertEqual(activity.updated_at, mockNow)
        XCTAssertEqual(activity.latestRelevantUpdate, mockYesterday)
    }

    func testConversationLatestMessagesEmpty() {
        let activity = APIActivity.make(
            updated_at: mockNow,
            type: .conversation,
            latest_messages: []
        )

        XCTAssertEqual(activity.updated_at, mockNow)
        XCTAssertEqual(activity.latestRelevantUpdate, mockNow)
    }

    func testConversationLatesMessagesNil() {
        let activity = APIActivity.make(
            updated_at: mockNow,
            type: .conversation,
            latest_messages: nil
        )

        XCTAssertEqual(activity.updated_at, mockNow)
        XCTAssertEqual(activity.latestRelevantUpdate, mockNow)
    }

    func testNotConversationLatesMessagesNil() {
        let activity = APIActivity.make(
            updated_at: mockNow,
            type: .assessmentRequest,
            latest_messages: nil
        )

        XCTAssertEqual(activity.updated_at, mockNow)
        XCTAssertEqual(activity.latestRelevantUpdate, mockNow)
    }

    func testNotConversationLatesMessagesEmpty() {
        let activity = APIActivity.make(
            updated_at: mockNow,
            type: .conference,
            latest_messages: []
        )

        XCTAssertEqual(activity.updated_at, mockNow)
        XCTAssertEqual(activity.latestRelevantUpdate, mockNow)
    }
}

