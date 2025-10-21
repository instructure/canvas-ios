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
import TestsFoundation

class DiscussionEntryTests: CoreTestCase {
    func testSave() {
        let apiEntry = APIDiscussionEntry.make()
        let entry = DiscussionEntry.make(from: apiEntry)
        XCTAssertEqual(entry.id, apiEntry.id.value)
        XCTAssertEqual(entry.message, apiEntry.message)
    }

    func testReplies() {
        let entry = DiscussionEntry.make(from: .make(replies: [
            .make(id: "2")
        ]))
        XCTAssertEqual(entry.replies.count, 1)
        entry.replies = []
        XCTAssertEqual(entry.replies.count, 0)
    }

    func testLikeCount() {
        let entry = DiscussionEntry.make(from: .make(rating_sum: 5))
        XCTAssertEqual(entry.likeCountText, "5 likes")
    }
}
