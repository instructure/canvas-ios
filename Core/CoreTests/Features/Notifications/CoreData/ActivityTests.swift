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
@testable import Core
import XCTest
import TestsFoundation

class ActivityTests: CoreTestCase {
    func testModel() {
        let url = URL(string: "/courses/1/assignments/1")
        let a = Activity.make(from: .make(course_id: "1", assignment: .make(id: "12", html_url: url)))
        let all: [Activity] =  databaseClient.fetch()
        XCTAssertEqual(all.count, 1)
        let aa = try! XCTUnwrap( all.first )

        XCTAssertEqual(a.id, aa.id)
        XCTAssertEqual(a.context?.canvasContextID, aa.context?.canvasContextID)
        XCTAssertEqual(a.htmlURL, aa.htmlURL)
        XCTAssertEqual(a.message, aa.message)
        XCTAssertEqual(a.title, aa.title)
        XCTAssertEqual(a.assignmentURL, url)
        XCTAssertEqual(a.announcementId, "123")
    }

    // MARK: - Save - isDiscussionSubmission

    func test_saveIsDiscussionSubmission_whenTypeIsSubmissionAndHasDiscussionTopic_shouldBeTrue() {
        let testee = saveActivity(.make(
            type: .submission,
            assignment: .make(discussion_topic: .make())
        ))

        XCTAssertEqual(testee.isDiscussionSubmission, true)
    }

    func test_saveIsDiscussionSubmission_whenTypeIsSubmissionAndHasNoDiscussionTopic_shouldBeFalse() {
        let testee = saveActivity(.make(
            type: .submission,
            assignment: .make(discussion_topic: nil)
        ))

        XCTAssertEqual(testee.isDiscussionSubmission, false)
    }

    func test_saveIsDiscussionSubmission_whenTypeIsNotSubmissionAndHasDiscussionTopic_shouldBeFalse() {
        let testee = saveActivity(.make(
            type: .message,
            assignment: .make(discussion_topic: .make())
        ))

        XCTAssertEqual(testee.isDiscussionSubmission, false)
    }

    // MARK: - Save - discussionCheckpointStep

    func test_save_shouldSetDiscussionCheckpointStep() {
        let activities = [
            saveActivity(id: "0", sub_assignment_tag: "reply_to_topic"),
            saveActivity(id: "1", sub_assignment_tag: "reply_to_entry"),
            saveActivity(id: "2", sub_assignment_tag: "some_unknown_tag"),
            saveActivity(id: "3", sub_assignment_tag: nil)
        ]

        XCTAssertEqual(activities.count, 4)

        let steps = activities.map { $0.discussionCheckpointStep }
        XCTAssertEqual(steps, [.replyToTopic, .requiredReplies(0), nil, nil])
    }

    // MARK: - Private helpers

    private func saveActivity(_ apiActivity: APIActivity) -> Activity {
        Activity.save(apiActivity, in: databaseClient)
    }

    private func saveActivity(id: String, sub_assignment_tag: String?) -> Activity {
        saveActivity(
            .make(
                id: ID(id),
                assignment: .make(
                    sub_assignment_tag: sub_assignment_tag,
                    discussion_topic: .make(
                        reply_to_entry_required_count: 0
                    )
                )
            )
        )
    }
}
