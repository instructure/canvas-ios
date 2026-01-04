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

class CDAssignmentCheckpointTests: CoreTestCase {

    private static let testData = (
        assignmentId: "some assignmentId",
        assignmentName: "some assignmentName",
        tag: "some tag",
        pointsPossible: 42.5,
        date1: Date.make(year: 2020, month: 1, day: 1),
        date2: Date.make(year: 2020, month: 2, day: 1),
        date3: Date.make(year: 2020, month: 3, day: 1)
    )
    private lazy var testData = Self.testData

    // MARK: - Save vs Update

    func test_save_shouldPersistModel() {
        let savedModel = saveModel(.make())
        let fetchedModel: CDAssignmentCheckpoint? = databaseClient.fetch().first

        XCTAssertEqual(savedModel.objectID, fetchedModel?.objectID)
    }

    func test_save_whenEntityNotExists_shouldCreateNewEntity() {
        let model11 = saveModel(.make(tag: "tag 1"), assignmentId: "id 1")
        let model12 = saveModel(.make(tag: "tag 1"), assignmentId: "id 2")
        let model21 = saveModel(.make(tag: "tag 2"), assignmentId: "id 1")
        let model22 = saveModel(.make(tag: "tag 2"), assignmentId: "id 2")

        XCTAssertNotEqual(model11.objectID, model12.objectID)
        XCTAssertNotEqual(model11.objectID, model21.objectID)
        XCTAssertNotEqual(model11.objectID, model22.objectID)
    }

    func test_save_whenEntityExists_shouldUpdateEntity() {
        let model1 = saveModel(.make(tag: "1", name: "old name"))
        let model2 = saveModel(.make(tag: "1", name: "new name"))

        XCTAssertEqual(model1.objectID, model2.objectID)
        XCTAssertEqual(model1.assignmentName, "new name")
    }

    // MARK: - Save Properties

    func test_saveBasicProperties() {
        let testee = saveModel(
            .make(
                tag: testData.tag,
                name: testData.assignmentName,
                points_possible: testData.pointsPossible,
                due_at: testData.date1,
                unlock_at: testData.date2,
                lock_at: testData.date3
            ),
            assignmentId: testData.assignmentId
        )

        XCTAssertEqual(testee.assignmentId, testData.assignmentId)
        XCTAssertEqual(testee.assignmentName, testData.assignmentName)
        XCTAssertEqual(testee.tag, testData.tag)
        XCTAssertEqual(testee.pointsPossible, testData.pointsPossible)
        XCTAssertEqual(testee.dueDate, testData.date1)
        XCTAssertEqual(testee.unlockDate, testData.date2)
        XCTAssertEqual(testee.lockDate, testData.date3)
    }

    func test_saveIsOnlyVisibleToOverrides() {
        // default should be false
        var testee = saveModel(
            .make(only_visible_to_overrides: nil)
        )
        XCTAssertEqual(testee.isOnlyVisibleToOverrides, false)

        testee = saveModel(
            .make(only_visible_to_overrides: true)
        )
        XCTAssertEqual(testee.isOnlyVisibleToOverrides, true)

        testee = saveModel(
            .make(only_visible_to_overrides: false)
        )
        XCTAssertEqual(testee.isOnlyVisibleToOverrides, false)
    }

    func test_saveOverrides_whenNilOrEmpty() {
        var testee = saveModel(
            .make(overrides: nil)
        )
        XCTAssertEqual(testee.overrides.isEmpty, true)

        testee = saveModel(
            .make(overrides: [])
        )
        XCTAssertEqual(testee.overrides.isEmpty, true)

        // set some value
        testee = saveModel(
            .make(overrides: [.make()])
        )
        XCTAssertEqual(testee.overrides.isEmpty, false)

        // nil should not clear values
        testee = saveModel(
            .make(overrides: nil)
        )
        XCTAssertEqual(testee.overrides.isEmpty, false)

        // [] should clear values
        testee = saveModel(
            .make(overrides: [])
        )
        XCTAssertEqual(testee.overrides.isEmpty, true)
    }

    func test_saveOverrides_whenNotEmpty() {
        let testee = saveModel(
            .make(
                tag: testData.tag,
                overrides: [
                    .make(id: "1", assignment_id: testData.assignmentId, title: "over1"),
                    .make(id: "2", assignment_id: testData.assignmentId, title: "over2")
                ]
            ),
            assignmentId: testData.assignmentId
        )

        let sortedOverrides = testee.overrides.sorted(by: comparing(\.title))
        XCTAssertEqual(sortedOverrides.count, 2)
        XCTAssertEqual(sortedOverrides.first?.title, "over1")
        XCTAssertEqual(sortedOverrides.last?.title, "over2")

        let fetchedOverrides: [AssignmentOverride] = databaseClient
            .all(where: \.assignmentID, equals: testData.assignmentId)
            .sorted(by: comparing(\.title))
        XCTAssertEqual(fetchedOverrides.count, 2)
        XCTAssertEqual(fetchedOverrides.first?.title, "over1")
        XCTAssertEqual(fetchedOverrides.last?.title, "over2")
    }

    // MARK: - Private Helpers

    private func saveModel(
        _ item: APIAssignmentCheckpoint,
        requiredReplyCount: Int? = nil,
        assignmentId: String = testData.assignmentId
    ) -> CDAssignmentCheckpoint {
        CDAssignmentCheckpoint.save(
            item,
            requiredReplyCount: requiredReplyCount,
            assignmentId: assignmentId,
            in: databaseClient
        )
    }
}

private func comparing<R, V: Comparable>(_ keyPath: ReferenceWritableKeyPath<R, V?>, nilDefault: Bool = true) -> (R, R) -> Bool {
    return { lhs, rhs in
        let lhsValue: V? = lhs[keyPath: keyPath]
        let rhsValue: V? = rhs[keyPath: keyPath]
        if let lhsValue, let rhsValue {
            return lhsValue < rhsValue
        }
        return nilDefault
    }
}
