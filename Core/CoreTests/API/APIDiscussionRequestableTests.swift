//
// Copyright (C) 2018-present Instructure, Inc.
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
