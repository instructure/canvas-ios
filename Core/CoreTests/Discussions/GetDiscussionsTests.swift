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

class GetDiscussionsTests: CoreTestCase {
    let context = Context(.course, id: "1")

    func testGetDiscussionTopic() {
        let useCase = GetDiscussionTopic(context: context, topicID: "2")
        XCTAssertEqual(useCase.cacheKey, "courses/1/discussions/2")
        XCTAssertEqual(useCase.request.context.canvasContextID, "course_1")
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(DiscussionTopic.id), equals: "2"))
    }

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

    func testGetDiscussionEntry() {
        let useCase = GetDiscussionEntry(context: context, topicID: "2", entryID: "3")
        XCTAssertEqual(useCase.scope, .where(#keyPath(DiscussionEntry.id), equals: "3"))
    }

    func testCreateDiscussionReply() {
        let useCase = CreateDiscussionReply(context: context, topicID: "2", message: "replied")
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.topicID, "2")
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        useCase.write(response: .make(), urlResponse: nil, to: databaseClient)
        let reply: DiscussionEntry? = databaseClient.first(where: #keyPath(DiscussionEntry.id), equals: "1")
        XCTAssertNotNil(reply)
    }

    func testUpdateDiscussionReply() {
        let useCase = UpdateDiscussionReply(context: context, topicID: "2", entryID: "1", message: "updated")
        XCTAssertNil(useCase.cacheKey)
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        let reply = DiscussionEntry.make()
        useCase.write(response: .make(message: "updated"), urlResponse: nil, to: databaseClient)
        XCTAssertEqual(reply.message, "updated")
    }

    func testMarkDiscussionTopicRead() {
        let useCase = MarkDiscussionTopicRead(context: context, topicID: "1", isRead: true)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
    }

    let emptyResponse = HTTPURLResponse(url: .make(), statusCode: 204, httpVersion: nil, headerFields: nil)
    func testMarkDiscussionEntriesRead() {
        let useCase = MarkDiscussionEntriesRead(context: context, topicID: "1", isRead: true, isForcedRead: true)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient))
        let entry = DiscussionEntry.make()
        let topic = DiscussionTopic.make()
        useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isRead, true)
        XCTAssertEqual(entry.isForcedRead, true)
        XCTAssertEqual(topic.unreadCount, 0)
        let unmark = MarkDiscussionEntriesRead(context: context, topicID: "1", isRead: false, isForcedRead: false)
        unmark.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isRead, false)
        XCTAssertEqual(entry.isForcedRead, false)
        XCTAssertEqual(topic.unreadCount, 1)
    }

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

    func testRateDiscussionEntry() {
        let useCase = RateDiscussionEntry(context: context, topicID: "1", entryID: "1", isLiked: true)
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.entryID, "1")
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient))
        let entry = DiscussionEntry.make()
        useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isLikedByMe, true)
        XCTAssertEqual(entry.likeCount, 1)
        let unmark = RateDiscussionEntry(context: context, topicID: "1", entryID: "1", isLiked: false)
        unmark.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isLikedByMe, false)
        XCTAssertEqual(entry.likeCount, 0)
    }

    func testDeleteDiscussionEntry() {
        let useCase = DeleteDiscussionEntry(context: context, topicID: "1", entryID: "1")
        XCTAssertNil(useCase.cacheKey)
        XCTAssertEqual(useCase.request.entryID, "1")
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: nil, to: databaseClient))
        XCTAssertNoThrow(useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient))
        let entry = DiscussionEntry.make()
        useCase.write(response: nil, urlResponse: emptyResponse, to: databaseClient)
        XCTAssertEqual(entry.isRemoved, true)
    }

    func testPageIndexSaveOnGetAnnouncements() {
        let testee = GetAnnouncements(context: .course("1"))
        let requestedURL = URL(string: "/courses/1/announcements?page=2&per_page=100")!
        let urlResponse = URLResponse(url: requestedURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let announcement = DiscussionTopic.make()

        XCTAssertEqual(announcement.position, Int.max)
        testee.write(response: [.make()], urlResponse: urlResponse, to: databaseClient)
        XCTAssertEqual(announcement.position, 100)
    }
}
