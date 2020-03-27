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
import TestsFoundation
import PactConsumerSwift
@testable import Core

class DiscussionPactTests: PactTestCase {
    let course = APICourse.make(id: "1")

    enum ProviderStates: String {
        case discussion = "a teacher in a course with a discussion"
        case discussionWithReply = "a teacher in a course with a discussion and a student reply"
    }

    override func setUp() {
        provider.user = "Teacher1"
        super.setUp()
    }

    func testPostDiscussionTopic() throws {
        let topic = APIDiscussionTopic.make()
        let body = PostDiscussionTopicRequest.Body(
            title: "title",
            message: "message",
            published: true,
            assignment: nil
        )
        let request = PostDiscussionTopicRequest(context: course, body: body)
        try provider.uponReceiving(
            "Post discussion topic",
            with: request,
            respondWith: topic
        ).given(ProviderStates.discussion.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }

    func testPostDiscussionEntry() throws {
        let entry = APIDiscussionEntry.make()
        let body = PostDiscussionEntryRequest.Body(message: "message")
        let request = PostDiscussionEntryRequest(context: course, topicID: "1", body: body)

        try provider.uponReceiving(
            "Post discussion enty",
            with: request,
            respondWith: entry,
            status: 201
        ).given(ProviderStates.discussion.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }

    func testListDiscussionEntries() throws {
        let entry = APIDiscussionEntry.make()
        let request = ListDiscussionEntriesRequest(context: course, topicID: "1")

        try provider.uponReceiving(
            "List discussion entries",
            with: request,
            respondWithArrayLike: entry
        ).given(ProviderStates.discussionWithReply.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }

    func testGetTopicRequest() throws {
        let topic = APIDiscussionTopic.make()
        let request = GetTopicRequest(context: course, topicID: "1")

        try provider.uponReceiving(
            "Get topic",
            with: request,
            respondWith: topic
        ).given(ProviderStates.discussion.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }

    func testGetFullTopicRequest() throws {
        let fullTopic = APIDiscussionFullTopic.make(
            view: [APIDiscussionEntry.make()]
        )
        let request = GetFullTopicRequest(context: course, topicID: "1")

        try provider.uponReceiving(
            "Get full topic",
            with: request,
            respondWith: fullTopic
        ).given(ProviderStates.discussionWithReply.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }

    func testListDiscussionTopics() throws {
        let topic = APIDiscussionTopic.make()
        let request = ListDiscussionTopicsRequest(context: course)
        try provider.uponReceiving(
            "List discussion topics",
            with: request,
            respondWithArrayLike: topic
        ).given(ProviderStates.discussion.rawValue)

        provider.run { testComplete in
            self.environment.api.makeRequest(request) { _, _, _ in
                testComplete()
            }
        }
    }
}
