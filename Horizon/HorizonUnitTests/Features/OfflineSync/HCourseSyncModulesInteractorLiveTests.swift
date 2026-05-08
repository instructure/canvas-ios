//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
@testable import Horizon
import XCTest
import TestsFoundation
import Combine

final class HCourseSyncModulesInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        courseID: "course 1",
        moduleID1: "module 1",
        moduleID2: "module 2",
        itemID1: "item 1",
        itemID2: "item 2",
        itemID3: "item 3"
    )
    private lazy var testData = Self.testData

    private var testee: HCourseSyncModulesInteractorLive!

    override func setUp() {
        super.setUp()
        testee = HCourseSyncModulesInteractorLive()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - getModuleItems

    func test_getModuleItems_withNoModules_shouldReturnEmptyArray() {
        api.mock(GetModulesRequest(courseID: testData.courseID), value: [])

        XCTAssertSingleOutputAndFinish(testee.getModuleItems(courseId: testData.courseID)) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    func test_getModuleItems_withModuleWithNoItems_shouldReturnEmptyArray() {
        api.mock(
            GetModulesRequest(courseID: testData.courseID),
            value: [.make(id: ID(testData.moduleID1))]
        )
        mockModuleItems(moduleID: testData.moduleID1, items: [])

        XCTAssertSingleOutputAndFinish(testee.getModuleItems(courseId: testData.courseID)) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    func test_getModuleItems_withModuleWithItems_shouldReturnThoseItems() {
        api.mock(
            GetModulesRequest(courseID: testData.courseID),
            value: [.make(id: ID(testData.moduleID1))]
        )
        mockModuleItems(moduleID: testData.moduleID1, items: [
            .make(id: ID(testData.itemID1), module_id: ID(testData.moduleID1)),
            .make(id: ID(testData.itemID2), module_id: ID(testData.moduleID1))
        ])
        mockItemSequence(itemID: testData.itemID1)
        mockItemSequence(itemID: testData.itemID2)

        XCTAssertSingleOutputAndFinish(testee.getModuleItems(courseId: testData.courseID)) { items in
            XCTAssertEqual(items.count, 2)
        }
    }

    func test_getModuleItems_withMultipleModules_shouldReturnAllItemsFlattened() {
        api.mock(
            GetModulesRequest(courseID: testData.courseID),
            value: [
                .make(id: ID(testData.moduleID1), position: 1),
                .make(id: ID(testData.moduleID2), position: 2)
            ]
        )
        mockModuleItems(moduleID: testData.moduleID1, items: [
            .make(id: ID(testData.itemID1), module_id: ID(testData.moduleID1))
        ])
        mockModuleItems(moduleID: testData.moduleID2, items: [
            .make(id: ID(testData.itemID2), module_id: ID(testData.moduleID2)),
            .make(id: ID(testData.itemID3), module_id: ID(testData.moduleID2))
        ])
        mockItemSequence(itemID: testData.itemID1)
        mockItemSequence(itemID: testData.itemID2)
        mockItemSequence(itemID: testData.itemID3)

        XCTAssertSingleOutputAndFinish(testee.getModuleItems(courseId: testData.courseID)) { items in
            XCTAssertEqual(items.count, 3)
        }
    }

    func test_getModuleItems_withModuleItems_shouldPrefetchEachItemSequence() {
        api.mock(
            GetModulesRequest(courseID: testData.courseID),
            value: [.make(id: ID(testData.moduleID1))]
        )
        mockModuleItems(moduleID: testData.moduleID1, items: [
            .make(id: ID(testData.itemID1), module_id: ID(testData.moduleID1)),
            .make(id: ID(testData.itemID2), module_id: ID(testData.moduleID1))
        ])
        let seq1 = mockItemSequence(itemID: testData.itemID1)
        let seq2 = mockItemSequence(itemID: testData.itemID2)
        seq1.suspend()
        seq2.suspend()

        var subscriptions = Set<AnyCancellable>()
        testee.getModuleItems(courseId: testData.courseID)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)
        drainMainQueue()

        XCTAssertEqual(seq1.queue.isEmpty, false)
        XCTAssertEqual(seq2.queue.isEmpty, false)
    }

    func test_getModuleItems_whenAPIFails_shouldPropagateError() {
        api.mock(
            GetModulesRequest(courseID: testData.courseID),
            error: NSError.instructureError("network error")
        )

        XCTAssertFailure(testee.getModuleItems(courseId: testData.courseID))
    }

    // MARK: - Private helpers

    private func mockModuleItems(moduleID: String, items: [APIModuleItem]) {
        api.mock(
            GetModuleItemsRequest(
                courseID: testData.courseID,
                moduleID: moduleID,
                include: [.content_details, .mastery_paths]
            ),
            value: items
        )
    }

    @discardableResult
    private func mockItemSequence(itemID: String) -> APIMock {
        api.mock(
            GetModuleItemSequence(
                courseID: testData.courseID,
                assetType: .moduleItem,
                assetID: itemID
            ),
            value: .make()
        )
    }
}
