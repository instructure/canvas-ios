//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation

class CDModuleItemDiscussionCheckpointTests: CoreTestCase {
    private typealias APICheckpoint = APIModuleItemsDiscussionCheckpoints.DiscussionCheckpoint

    private static let testData = (
        moduleItemId: "some moduleItemId",
        checkpoint1: APICheckpoint.make(
            tag: "some tag1",
            dueAt: Date.make(year: 2025, month: 1, day: 15),
            pointsPossible: 142
        ),
        checkpoint2: APICheckpoint.make(
            tag: "some tag2",
            dueAt: Date.make(year: 2025, month: 1, day: 20),
            pointsPossible: 242
        )
    )
    private lazy var testData = Self.testData

    // MARK: - Save

    func test_save_shouldPersistModels() {
        let savedModels = saveModels(checkpointsData: .make(
            checkpoints: [testData.checkpoint1, testData.checkpoint2]
        ))
        let fetchedModels: [CDModuleItemDiscussionCheckpoint] = databaseClient.fetch()

        XCTAssertEqual(savedModels.count, 2)
        XCTAssertEqual(fetchedModels.count, 2)

        let savedModelsSet = Set(savedModels.map(\.objectID))
        let fetchedModelsSet = Set(fetchedModels.map(\.objectID))
        XCTAssertEqual(savedModelsSet, fetchedModelsSet)
    }

    func test_save_withNoCheckpoints_shouldSaveNothing() {
        let savedModels = saveModels(checkpointsData: .make(checkpoints: []))
        let fetchedModels: [CDModuleItemDiscussionCheckpoint] = databaseClient.fetch()

        XCTAssertEqual(savedModels.count, 0)
        XCTAssertEqual(fetchedModels.count, 0)
    }

    // MARK: - Save Properties

    func test_save_shouldSetBasicProperties() {
        let testee = saveModels(checkpointsData: .make(
            checkpoints: [testData.checkpoint1, testData.checkpoint2]
        ))

        XCTAssertEqual(testee.count, 2)

        let model1 = testee.first
        XCTAssertEqual(model1?.moduleItemId, testData.moduleItemId)
        XCTAssertEqual(model1?.tag, testData.checkpoint1.tag)
        XCTAssertEqual(model1?.pointsPossible, testData.checkpoint1.pointsPossible)
        XCTAssertEqual(model1?.dueDate, testData.checkpoint1.dueAt)

        let model2 = testee.last
        XCTAssertEqual(model2?.moduleItemId, testData.moduleItemId)
        XCTAssertEqual(model2?.tag, testData.checkpoint2.tag)
        XCTAssertEqual(model2?.pointsPossible, testData.checkpoint2.pointsPossible)
        XCTAssertEqual(model2?.dueDate, testData.checkpoint2.dueAt)
    }

    func test_save_shouldSetDiscussionCheckpointStep() {
        let testee = saveModels(checkpointsData: .make(
            checkpoints: [
                .make(tag: "reply_to_topic"),
                .make(tag: "reply_to_entry"),
                .make(tag: "some_unknown_tag")
            ],
            replyToEntryRequiredCount: 3
        ))

        XCTAssertEqual(testee.count, 3)

        let steps = testee.map { $0.discussionCheckpointStep }
        XCTAssertEqual(steps, [.replyToTopic, .requiredReplies(3), nil])
    }

    // MARK: - Sorting

    func test_save_shouldReturnSortedCheckpoints() {
        let testee = saveModels(checkpointsData: .make(
            checkpoints: [
                .make(tag: "reply_to_entry"),
                .make(tag: "some_unknown_tag"),
                .make(tag: "reply_to_topic")
            ]
        ))

        XCTAssertEqual(testee.count, 3)

        let steps = testee.map { $0.discussionCheckpointStep }
        XCTAssertEqual(steps, [.replyToTopic, .requiredReplies(0), nil])
    }

    // MARK: - Private Helpers

    private func saveModels(
        checkpointsData: APIModuleItemsDiscussionCheckpoints.Data,
        moduleItemId: String = testData.moduleItemId
    ) -> [CDModuleItemDiscussionCheckpoint] {
        CDModuleItemDiscussionCheckpoint.save(
            checkpointsData: checkpointsData,
            moduleItemId: moduleItemId,
            in: databaseClient
        )
    }
}
