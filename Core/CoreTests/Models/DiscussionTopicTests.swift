//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
