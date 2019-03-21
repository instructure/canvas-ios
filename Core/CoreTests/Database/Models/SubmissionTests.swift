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

import Foundation
import XCTest
@testable import Core

class SubmissionTests: CoreTestCase {
    func testProperties() {
        let submission = Submission.make()

        submission.excused = nil
        XCTAssertNil(submission.excused)
        submission.excused = true
        XCTAssertEqual(submission.excused, true)

        submission.latePolicyStatus = nil
        XCTAssertNil(submission.latePolicyStatus)
        submission.latePolicyStatus = .late
        XCTAssertEqual(submission.latePolicyStatus, .late)

        submission.pointsDeducted = nil
        XCTAssertNil(submission.pointsDeducted)
        submission.pointsDeducted = 5
        XCTAssertEqual(submission.pointsDeducted, 5)

        submission.score = nil
        XCTAssertNil(submission.score)
        submission.score = 10
        XCTAssertEqual(submission.score, 10)

        submission.type = nil
        XCTAssertNil(submission.type)
        submission.type = .online_upload
        XCTAssertEqual(submission.type, .online_upload)

        submission.workflowState = .submitted
        XCTAssertEqual(submission.workflowState, .submitted)
        submission.workflowStateRaw = "bogus"
        XCTAssertEqual(submission.workflowState, .unsubmitted)

        submission.discussionEntries = [
            DiscussionEntry.make([ "id": "2" ]),
            DiscussionEntry.make([ "id": "1" ]),
        ]
        XCTAssertEqual(submission.discussionEntriesOrdered.first?.id, "1")
    }

    func testUserAssignmentScope() {
        let one = Submission.make(["assignmentID": "2", "attempt": 1, "userID": "3"])
        let two = Submission.make(["assignmentID": "2", "attempt": 2, "userID": "3"])
        let three = Submission.make(["assignmentID": "2", "attempt": 3, "userID": "3"])
        let other = Submission.make(["assignmentID": "7"])
        let list = environment.subscribe(Submission.self, .forUserOnAssignment("2", "3"))
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects, [one, two, three])
        XCTAssertEqual(objects?.contains(other), false)
    }

    func testMediaSubmission() {
        let submission = Submission.make(["mediaComment": MediaComment.make()])
        XCTAssertNotNil(submission.mediaComment)
    }

    func testIcon() {
        let submission = Submission.make()
        let map: [SubmissionType: UIImage.InstIconName] = [
            .basic_lti_launch: .lti,
            .external_tool: .lti,
            .discussion_topic: .discussion,
            .online_quiz: .quiz,
            .online_text_entry: .text,
            .online_url: .link,
        ]
        for (type, icon) in map {
            submission.type = type
            XCTAssertEqual(submission.icon, UIImage.icon(icon))
        }
        submission.type = .media_recording
        submission.mediaComment = MediaComment.make(["mediaTypeRaw": "audio"])
        XCTAssertEqual(submission.icon, UIImage.icon(.audio))
        submission.mediaComment?.mediaType = .video
        XCTAssertEqual(submission.icon, UIImage.icon(.video))

        submission.type = .online_upload
        submission.attachments = Set([ File.make([ "mimeClass": "pdf" ]) ])
        XCTAssertEqual(submission.icon, UIImage.icon(.pdf))

        submission.type = .on_paper
        XCTAssertNil(submission.icon)

        submission.type = nil
        XCTAssertNil(submission.icon)
    }

    func testSubtitle() {
        let submission = Submission.make([
            "attempt": 1,
            "body": "<a style=\"stuff\">Text</z>",
            "discussionEntries": Set([ DiscussionEntry.make([ "message": "<p>reply<p>" ]) ]),
            "attachments": Set([ File.make([ "size": 1234 ]) ]),
            "url": URL(string: "https://instructure.com"),
        ])
        let map: [SubmissionType: String] = [
            .basic_lti_launch: "Attempt 1",
            .external_tool: "Attempt 1",
            .discussion_topic: "reply",
            .online_quiz: "Attempt 1",
            .online_text_entry: "Text",
            .online_url: "https://instructure.com",
        ]
        for (type, subtitle) in map {
            submission.type = type
            XCTAssertEqual(submission.subtitle, subtitle)
        }
        submission.type = .media_recording
        submission.mediaComment = MediaComment.make(["mediaTypeRaw": "audio"])
        XCTAssertEqual(submission.subtitle, "Audio")
        submission.mediaComment?.mediaType = .video
        XCTAssertEqual(submission.subtitle, "Video")

        submission.type = .online_upload
        XCTAssertEqual(submission.subtitle, "1 KB")

        submission.type = .on_paper
        XCTAssertNil(submission.subtitle)

        submission.type = nil
        XCTAssertNil(submission.subtitle)
    }
}
