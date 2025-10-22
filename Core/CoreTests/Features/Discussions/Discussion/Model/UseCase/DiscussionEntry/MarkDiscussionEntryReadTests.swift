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

class MarkDiscussionEntryReadTests: CoreTestCase {
    let context = Context(.course, id: "1")
    let emptyResponse = HTTPURLResponse(url: .make(), statusCode: 204, httpVersion: nil, headerFields: nil)

    func testMarkDiscussionEntryRead() {
        let useCase = MarkDiscussionEntryRead(context: context, topicID: "1", entryID: "1", isRead: true, isForcedRead: true)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient))
        let entry = DiscussionEntry.make()
        let topic = DiscussionTopic.make()
        useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isRead, true)
        XCTAssertEqual(entry.isForcedRead, true)
        XCTAssertEqual(topic.unreadCount, 0)
    }
}
