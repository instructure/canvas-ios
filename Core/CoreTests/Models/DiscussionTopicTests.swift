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
        let topic = DiscussionTopic.make(from: .make(title: "Graded Discussion"))

        XCTAssertEqual(topic.id, "1")
        XCTAssertEqual(topic.title, "Graded Discussion")
    }

    func testSave() {
        let api = APIDiscussionTopic.make()
        DiscussionTopic.save(api, in: databaseClient)
        let topics: [DiscussionTopic] =  databaseClient.fetch()
        XCTAssertEqual(topics.count, 1)
    }

    func testHtml() {
        let topic = DiscussionTopic.make(from: .make(
            posted_at: DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 4, day: 22).date,
            author: .make(display_name: "Strong Bad")
        ))
        XCTAssertTrue(topic.html.contains("SB"))
        XCTAssertTrue(topic.html.contains("Strong Bad"))
        XCTAssertTrue(topic.html.contains("Apr 22, 2019"))
    }

    func testHTMLWithNoAuthorName() {
        let topic = DiscussionTopic.make(from: .make(
            author: .make(display_name: nil)
        ))
        XCTAssertFalse(topic.html.contains("Strong Bad"))
    }

    func testHtmlAttachmentIcon() {
        let api = APIDiscussionTopic.make(attachments: [ APIFile.make() ])
        DiscussionTopic.save(api, in: databaseClient)
        let topics: [DiscussionTopic] =  databaseClient.fetch()
        XCTAssertTrue(topics.first!.html.contains("<svg"))
        XCTAssertFalse(DiscussionTopic.make().html.contains("<svg"))
    }
}
