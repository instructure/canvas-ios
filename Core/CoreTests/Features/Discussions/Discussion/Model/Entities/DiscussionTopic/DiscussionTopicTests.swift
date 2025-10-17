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

    // MARK: - Checkpoints

    func test_updateIsCheckpointed() {
        // default should be false
        var item = APIDiscussionTopic.make(is_checkpointed: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.isCheckpointed, false)

        item = APIDiscussionTopic.make(is_checkpointed: true)
        testee = saveModel(item)
        XCTAssertEqual(testee.isCheckpointed, true)

        // nil should not clear value
        item = APIDiscussionTopic.make(is_checkpointed: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.isCheckpointed, true)

        item = APIDiscussionTopic.make(is_checkpointed: false)
        testee = saveModel(item)
        XCTAssertEqual(testee.isCheckpointed, false)
    }

    func test_updateRequiredReplyCount() {
        // default should be nil
        var item = APIDiscussionTopic.make(reply_to_entry_required_count: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.requiredReplyCount, nil)

        item = APIDiscussionTopic.make(reply_to_entry_required_count: 42)
        testee = saveModel(item)
        XCTAssertEqual(testee.requiredReplyCount, 42)

        // nil should not clear value
        item = APIDiscussionTopic.make(reply_to_entry_required_count: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.requiredReplyCount, 42)

        item = APIDiscussionTopic.make(reply_to_entry_required_count: 0)
        testee = saveModel(item)
        XCTAssertEqual(testee.requiredReplyCount, 0)
    }

    func test_updateHasSubAssignments() {
        // default should be false
        var item = APIDiscussionTopic.make(has_sub_assignments: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignments, false)

        item = APIDiscussionTopic.make(has_sub_assignments: true)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignments, true)

        // nil should not clear value
        item = APIDiscussionTopic.make(has_sub_assignments: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignments, true)

        item = APIDiscussionTopic.make(has_sub_assignments: false)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignments, false)
    }

    func test_updateCheckpoints_whenNilOrEmpty() {
        var item = APIDiscussionTopic.make(assignment: .make(), checkpoints: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.checkpoints.isEmpty, true)

        item = APIDiscussionTopic.make(assignment: .make(), checkpoints: [])
        testee = saveModel(item)
        XCTAssertEqual(testee.checkpoints.isEmpty, true)

        // set some value
        item = APIDiscussionTopic.make(assignment: .make(), checkpoints: [.make()])
        testee = saveModel(item)
        XCTAssertEqual(testee.checkpoints.isEmpty, false)

        // nil should not clear values
        item = APIDiscussionTopic.make(assignment: .make(), checkpoints: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.checkpoints.isEmpty, false)

        // [] should clear values
        item = APIDiscussionTopic.make(assignment: .make(), checkpoints: [])
        testee = saveModel(item)
        XCTAssertEqual(testee.checkpoints.isEmpty, true)
    }

    func test_updateCheckpoints_whenNotEmpty() {
        let item = APIDiscussionTopic.make(
            assignment: .make(id: "ass id"),
            id: "disc id",
            checkpoints: [
                .make(tag: "tag1"),
                .make(tag: "tag2")
            ]
        )
        let testee = saveModel(item)

        let sortedCheckpoints = testee.checkpoints.sorted(by: \.tag)
        XCTAssertEqual(sortedCheckpoints.count, 2)
        XCTAssertEqual(sortedCheckpoints.first?.tag, "tag1")
        XCTAssertEqual(sortedCheckpoints.last?.tag, "tag2")

        let fetchedCheckpoints: [CDAssignmentCheckpoint] = databaseClient
            .all(where: \.assignmentId, equals: "ass id")
            .sorted(by: \.tag)
        XCTAssertEqual(fetchedCheckpoints.count, 2)
        XCTAssertEqual(fetchedCheckpoints.first?.tag, "tag1")
        XCTAssertEqual(fetchedCheckpoints.last?.tag, "tag2")
    }

    // MARK: - Private Helpers

    private func saveModel(_ item: APIDiscussionTopic) -> DiscussionTopic {
        DiscussionTopic.save(item, in: databaseClient)
    }
}
