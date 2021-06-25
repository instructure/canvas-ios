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

import Foundation
import XCTest
@testable import Core

class DiscussionTopicTests: CoreTestCase {
    func testProperties() {
        let topic = DiscussionTopic.make(from: .make(
            attachments: [.make()],
            title: "Graded Discussion"
        ))

        XCTAssertEqual(topic.id, "1")
        XCTAssertEqual(topic.title, "Graded Discussion")
        XCTAssertEqual(topic.attachments?.count, 1)
    }

    func testSave() {
        let api = APIDiscussionTopic.make()
        DiscussionTopic.save(api, in: databaseClient)
        let topics: [DiscussionTopic] =  databaseClient.fetch()
        XCTAssertEqual(topics.count, 1)
    }

    func testSavePosition() {
        let api = APIDiscussionTopic.make()
        DiscussionTopic.save(api, apiPosition: 99, in: databaseClient)
        let topics: [DiscussionTopic] =  databaseClient.fetch()
        XCTAssertEqual(topics.first!.position, 99)
    }
}
