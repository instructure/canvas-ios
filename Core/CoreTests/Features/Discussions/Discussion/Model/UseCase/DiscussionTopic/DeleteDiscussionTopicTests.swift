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

class DeleteDiscussionTopicTests: CoreTestCase {
    let context = Context(.course, id: "1")

    func testDeleteDiscussionTopic() {
        DiscussionTopic.make()
        let useCase = DeleteDiscussionTopic(context: context, topicID: "1")
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.topicID, "1")
        XCTAssertEqual(useCase.scope, .where(#keyPath(DiscussionTopic.id), equals: "1"))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        useCase.write(response: .init(discussion_topic: .init(id: "1")), urlResponse: nil, to: databaseClient)
        let topics: [DiscussionTopic] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(topics.count, 0)
    }
}
