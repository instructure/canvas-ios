//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class APIDiscussionTests: XCTestCase {
    let context = Context(.course, id: "1")

    func testPostDiscussionTopicRequest() {
        let request = PostDiscussionTopicRequest(context: context, form: [
            .title: .string("Sorted")
        ])

        XCTAssertEqual(request.path, "courses/1/discussion_topics")
        XCTAssertEqual(request.method, .post)
        XCTAssertNotNil(request.form)
    }

    func testPostDiscussionEntryRequest() {
        let url = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "png")!
        let request = PostDiscussionEntryRequest(context: context, topicID: "42", message: "Hello There", attachment: url)

        XCTAssertEqual(request.path, "courses/1/discussion_topics/42/entries")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.form?.count, 2)
        XCTAssertEqual(request.form?.first?.key, "message")
        XCTAssertEqual(request.form?.first?.value, .string("Hello There"))
        XCTAssertEqual(request.form?.last?.key, "attachment")
        XCTAssertEqual(request.form?.last?.value, .file(
            filename: url.lastPathComponent,
            type: "application/octet-stream",
            at: url
        ))

        let reply = PostDiscussionEntryRequest(context: context, topicID: "42", entryID: "1", message: "Reply")
        XCTAssertEqual(reply.path, "courses/1/discussion_topics/42/entries/1/replies")
    }

    func testPutDiscussionEntryRequest() {
        let request = PutDiscussionEntryRequest(context: context, topicID: "42", entryID: "5", message: "Updated")

        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.path, "courses/1/discussion_topics/42/entries/5")
        XCTAssertEqual(request.body?.message, "Updated")
    }

    func testMarkDiscussionTopicReadRequest() {
        let mark = MarkDiscussionTopicReadRequest(context: context, topicID: "1", isRead: true)
        XCTAssertEqual(mark.method, .put)
        XCTAssertEqual(mark.path, "courses/1/discussion_topics/1/read")
        let unmark = MarkDiscussionTopicReadRequest(context: context, topicID: "1", isRead: false)
        XCTAssertEqual(unmark.method, .delete)
        XCTAssertEqual(unmark.path, "courses/1/discussion_topics/1/read")
    }

    func testMarkDiscussionEntriesReadRequest() {
        let mark = MarkDiscussionEntriesReadRequest(context: context, topicID: "1", isRead: true, isForcedRead: false)
        XCTAssertEqual(mark.method, .put)
        XCTAssertEqual(mark.path, "courses/1/discussion_topics/1/read_all")
        XCTAssertEqual(mark.query, [ .bool("forced_read_state", false) ])
        let unmark = MarkDiscussionEntriesReadRequest(context: context, topicID: "1", isRead: false, isForcedRead: true)
        XCTAssertEqual(unmark.method, .delete)
        XCTAssertEqual(unmark.path, "courses/1/discussion_topics/1/read_all")
        XCTAssertEqual(unmark.query, [ .bool("forced_read_state", true) ])
    }

    func testMarkDiscussionEntryReadRequest() {
        let mark = MarkDiscussionEntryReadRequest(context: context, topicID: "1", entryID: "2", isRead: true, isForcedRead: false)
        XCTAssertEqual(mark.method, .put)
        XCTAssertEqual(mark.path, "courses/1/discussion_topics/1/entries/2/read")
        XCTAssertEqual(mark.query, [ .bool("forced_read_state", false) ])
        let unmark = MarkDiscussionEntryReadRequest(context: context, topicID: "1", entryID: "2", isRead: false, isForcedRead: true)
        XCTAssertEqual(unmark.method, .delete)
        XCTAssertEqual(unmark.path, "courses/1/discussion_topics/1/entries/2/read")
        XCTAssertEqual(unmark.query, [ .bool("forced_read_state", true) ])
    }

    func testPostDiscussionEntryRatingRequest() {
        let mark = PostDiscussionEntryRatingRequest(context: context, topicID: "1", entryID: "2", isLiked: true)
        XCTAssertEqual(mark.method, .post)
        XCTAssertEqual(mark.path, "courses/1/discussion_topics/1/entries/2/rating")
        XCTAssertEqual(mark.body, [ "rating": 1 ])
        let unmark = PostDiscussionEntryRatingRequest(context: context, topicID: "1", entryID: "2", isLiked: false)
        XCTAssertEqual(unmark.method, .post)
        XCTAssertEqual(unmark.path, "courses/1/discussion_topics/1/entries/2/rating")
        XCTAssertEqual(unmark.body, [ "rating": 0 ])
    }

    func testDeleteDiscussionEntryRequest() {
        let request = DeleteDiscussionEntryRequest(context: context, topicID: "1", entryID: "1")
        XCTAssertEqual(request.method, .delete)
        XCTAssertEqual(request.path, "courses/1/discussion_topics/1/entries/1")
    }
}

class ListDiscussionEntriesRequestTests: XCTestCase {
    func testPath() {
        let request = ListDiscussionEntriesRequest(context: .course("1"), topicID: "2")
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2/entries")
    }
}

class GetDiscussionTopicRequestTests: XCTestCase {
    func testPath() {
        let request = GetDiscussionTopicRequest(context: .course("1"), topicID: "2")
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2")
    }

    func testQuery() {
        let request = GetDiscussionTopicRequest(context: .course("1"), topicID: "2", include: [.allDates, .overrides, .sections, .sectionsUserCount])
        XCTAssertEqual(request.query, [
            .include(["all_dates", "overrides", "sections", "section_user_count"])
        ])
    }
}

class GetDiscussionViewRequestTests: XCTestCase {
    func testPath() {
        let request = GetDiscussionViewRequest(context: .course("1"), topicID: "2")
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2/view")
    }

    func testQuery() {
        let request = GetDiscussionViewRequest(context: .course("1"), topicID: "2", includeNewEntries: true)
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "include_new_entries", value: "1")])
    }
}

class ListDiscussionTopicsRequestTests: XCTestCase {
    func testPath() {
        let request = GetDiscussionTopicsRequest(context: .course("1"))
        XCTAssertEqual(request.path, "courses/1/discussion_topics")
    }

    func testQuery() {
        let request = GetDiscussionTopicsRequest(context: .course("1"), perPage: 25, include: [.allDates, .overrides, .sections, .sectionsUserCount])
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "include[]", value: "all_dates"),
            URLQueryItem(name: "include[]", value: "overrides"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "section_user_count")
        ])
    }
}

class GetAllAnnouncementsRequestTests: XCTestCase {
    func testPath() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"])
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "announcements")
    }

    func testMinimalQuery() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"])
        XCTAssertEqual(request.query, [
            .array("context_codes", ["1", "2"]),
            .optionalBool("active_only", nil),
            .optionalBool("latest_only", nil),
            .optionalValue("start_date", nil),
            .optionalValue("end_date", nil)
        ])
    }

    func testExhaustiveQuery() {
        let request = GetAllAnnouncementsRequest(contextCodes: ["1", "2"], activeOnly: true, latestOnly: false)
        XCTAssertEqual(request.query, [
            .array("context_codes", ["1", "2"]),
            .optionalBool("active_only", true),
            .optionalBool("latest_only", false),
            .optionalValue("start_date", nil),
            .optionalValue("end_date", nil)
        ])
    }
}
