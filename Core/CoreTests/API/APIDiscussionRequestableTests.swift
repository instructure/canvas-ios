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

class APIDiscussionRequestableTests: XCTestCase {
    func testCreateGradedDiscussionRequest() {
        let assignment = APIAssignmentParameters(
            name: "A",
            description: "d",
            points_possible: 10,
            due_at: Date(),
            submission_types: [SubmissionType.discussion_topic],
            allowed_extensions: [],
            published: true,
            grading_type: .percent,
            lock_at: nil,
            unlock_at: nil
        )
        let expectedBody = PostDiscussionTopicRequest.Body(title: "T", message: "M", published: true, assignment: assignment)
        let context = ContextModel(.course, id: "1")
        let request = PostDiscussionTopicRequest(context: context, body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/discussion_topics")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }

    func testCreateDiscussionEntryRequest() {
        let expectedBody = PostDiscussionEntryRequest.Body(message: "Hello there")
        let context = ContextModel(.course, id: "1")
        let request = PostDiscussionEntryRequest(context: context, topicID: "42", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/discussion_topics/42/entries")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}

class ListDiscussionEntriesRequestTests: XCTestCase {
    func testPath() {
        let request = ListDiscussionEntriesRequest(context: ContextModel(.course, id: "1"), topicID: "2")
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2/entries")
    }
}

class GetTopicRequestsTests: XCTestCase {
    func testPath() {
        let request = GetTopicRequests(context: ContextModel(.course, id: "1"), topicID: "2")
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2")
    }

    func testQuery() {
        let request = GetTopicRequests(context: ContextModel(.course, id: "1"), topicID: "2", include: [.allDates, .overrides, .sections, .sectionsUserCount])
        XCTAssertEqual(request.query, [
            .include(["all_dates", "overrides", "sections", "section_user_count"]),
        ])
    }
}

class GetFullTopicRequestsTests: XCTestCase {
    func testPath() {
        let request = GetFullTopicRequests(context: ContextModel(.course, id: "1"), topicID: "2")
        XCTAssertEqual(request.path, "courses/1/discussion_topics/2/view")
    }

    func testQuery() {
        let request = GetFullTopicRequests(context: ContextModel(.course, id: "1"), topicID: "2", includeNewEntries: true)
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "include_new_entries", value: "1")])
    }
}

class ListDiscussionTopicsRequestTests: XCTestCase {
    func testPath() {
        let request = ListDiscussionTopicsRequest(context: ContextModel(.course, id: "1"))
        XCTAssertEqual(request.path, "courses/1/discussion_topics")
    }

    func testQuery() {
        let request = ListDiscussionTopicsRequest(context: ContextModel(.course, id: "1"), perPage: 25, include: [.allDates, .overrides, .sections, .sectionsUserCount])
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "include[]", value: "all_dates"),
            URLQueryItem(name: "include[]", value: "overrides"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "section_user_count"),
        ])
    }
}
