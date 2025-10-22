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

class GetDiscussionViewTests: CoreTestCase {
    let context = Context(.course, id: "1")

    func testGetDiscussionView() {
        let useCase = GetDiscussionView(context: context, topicID: "2")
        XCTAssertEqual(useCase.cacheKey, "courses/1/discussions/2/view")
        XCTAssertEqual(useCase.request.context.canvasContextID, "course_1")

        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        useCase.write(response: .make(
            participants: [
                .make(id: 1, display_name: "Teacher"),
                .make(id: 2, display_name: "Student")
            ],
            unread_entries: [1],
            forced_entries: [2],
            view: [
                .make(id: 1, user_id: 1, message: "teacher reply")
            ],
            new_entries: [
                .make(id: 2, user_id: 2, parent_id: 1, created_at: Date(), message: "student reply")
            ]
        ), urlResponse: nil, to: databaseClient)
        let entries: [DiscussionEntry] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].author?.id, "1")
        XCTAssertEqual(entries[0].isRead, false)
        XCTAssertEqual(entries[0].isForcedRead, false)
        XCTAssertEqual(entries[0].replies.count, 1)
        XCTAssertEqual(entries[0].replies[0].author?.id, "2")
        XCTAssertEqual(entries[0].replies[0].isRead, true)
        XCTAssertEqual(entries[0].replies[0].isForcedRead, true)
    }
}
