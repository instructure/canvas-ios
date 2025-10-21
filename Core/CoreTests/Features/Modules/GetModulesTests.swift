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

class GetModulesTests: CoreTestCase {

    private static let testData = (
        moduleId: "some moduleId",
        itemId1: "itemId1",
        itemId2: "itemId2",
        itemId3: "itemId3"
    )
    private lazy var testData = Self.testData

    let useCase = GetModules(courseID: "1")

    func testScopePredicate() {
        let yes = Module.make(from: .make(id: "1"), forCourse: "1")
        let no = Module.make(from: .make(id: "2"), forCourse: "2")
        XCTAssert(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: no))
    }

    func testScopeOrder() {
        let one = Module.make(from: .make(id: "1", position: 1))
        let two = Module.make(from: .make(id: "2", position: 2))
        let three = Module.make(from: .make(id: "3", position: 3))
        let order = useCase.scope.order[0]
        XCTAssertEqual(order.compare(one, to: two), .orderedAscending)
        XCTAssertEqual(order.compare(two, to: three), .orderedAscending)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "courses/1/modules/items")
    }

    func testWrite() {
        write(sections: [
            makeSection(moduleId: testData.moduleId, moduleItemIds: [""])
        ])

        let module: Module = databaseClient.fetch().first!
        XCTAssertEqual(module.id, testData.moduleId)
        XCTAssertEqual(module.courseID, "1")

        let moduleItem: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(moduleItem.moduleID, module.id)
        XCTAssertEqual(moduleItem.courseID, "1")
    }

    // MARK: - Discussion Checkpoints

    func test_write_whenMultipleModulesAndItemsHasCheckpoints_shouldSaveAllCheckpoints() {
        write(
            sections: [
                makeSection(moduleId: "a", moduleItemIds: [testData.itemId1, testData.itemId2]),
                makeSection(moduleId: "b", moduleItemIds: [testData.itemId3])
            ],
            discussionCheckpointsData: [
                testData.itemId1: .make(checkpoints: [.make(tag: "tag11"), .make(tag: "tag12")]),
                testData.itemId2: .make(checkpoints: [.make(tag: "tag21"), .make(tag: "tag22")]),
                testData.itemId3: .make(checkpoints: [.make(tag: "tag31"), .make(tag: "tag32")])
            ])

        let item1 = getModuleItem(id: testData.itemId1)
        let item1Tags = Set(item1?.discussionCheckpoints.map(\.tag) ?? [])
        XCTAssertEqual(item1Tags, Set(["tag11", "tag12"]))

        let item2 = getModuleItem(id: testData.itemId2)
        let item2Tags = Set(item2?.discussionCheckpoints.map(\.tag) ?? [])
        XCTAssertEqual(item2Tags, Set(["tag21", "tag22"]))

        let item3 = getModuleItem(id: testData.itemId3)
        let item3Tags = Set(item3?.discussionCheckpoints.map(\.tag) ?? [])
        XCTAssertEqual(item3Tags, Set(["tag31", "tag32"]))
    }

    func test_write_whenCheckpointsWereSavedBefore() {
        let oldPoints = 42.0
        let newPoints = 7.5

        // GIVEN - multiple items with checkpoints
        write(
            sections: [
                makeSection(moduleId: "a", moduleItemIds: [testData.itemId1, testData.itemId2]),
                makeSection(moduleId: "b", moduleItemIds: [testData.itemId3])
            ],
            discussionCheckpointsData: [
                testData.itemId1: .make(checkpoints: [.make(tag: "tag11"), .make(tag: "tag12", pointsPossible: oldPoints)]),
                testData.itemId2: .make(checkpoints: [.make(tag: "tag2")]),
                testData.itemId3: .make(checkpoints: [.make(tag: "tag3")])
            ])

        // WHEN - one item has new checkpoint data
        write(
            sections: [
                makeSection(moduleId: "a", moduleItemIds: [testData.itemId1])
            ],
            discussionCheckpointsData: [
                testData.itemId1: .make(checkpoints: [.make(tag: "tag12", pointsPossible: newPoints)])
            ])

        // THEN - clear only that one item's checkpoint data
        let item1 = getModuleItem(id: testData.itemId1)
        XCTAssertEqual(item1?.discussionCheckpoints.count, 1)
        XCTAssertEqual(item1?.discussionCheckpoints.first?.tag, "tag12")
        XCTAssertEqual(item1?.discussionCheckpoints.first?.pointsPossible, newPoints)

        let item2 = getModuleItem(id: testData.itemId2)
        XCTAssertEqual(item2?.discussionCheckpoints.first?.tag, "tag2")

        let item3 = getModuleItem(id: testData.itemId3)
        XCTAssertEqual(item3?.discussionCheckpoints.first?.tag, "tag3")
    }

    // MARK: - Private helpers

    private func write(
        sections: [GetModules.Response.Section],
        discussionCheckpointsData: [String: APIModuleItemsDiscussionCheckpoints.Data] = [:]
    ) {
        useCase.write(
            response: .init(
                sections: sections,
                discussionCheckpointsData: discussionCheckpointsData
            ),
            urlResponse: nil,
            to: databaseClient
        )
    }

    private func makeSection(
        moduleId: String = testData.moduleId,
        moduleItemIds: [String] = [testData.itemId1]
    ) -> GetModules.Response.Section {
        .init(
            module: .make(id: ID(moduleId)),
            items: moduleItemIds.map {
                .make(id: ID($0), module_id: ID(moduleId))
            }
        )
    }

    private func getModuleItem(id: String) -> ModuleItem? {
        let predicate = NSPredicate(\ModuleItem.id, equals: id)
        return databaseClient.fetch(predicate).first
    }
}
