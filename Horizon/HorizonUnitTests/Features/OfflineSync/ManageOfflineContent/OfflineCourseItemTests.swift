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

final class OfflineCourseItemTests: HorizonTestCase {

    private static let testData = (
        courseID: "course1",
        courseName: "course name 1",
        courseSize: "5 MB",
        subItemID1: "file1",
        subItemID2: "file2",
        subItemID3: "file3",
        subItemSizeInBytes1: Double(1_000_000),
        subItemSizeInBytes2: Double(2_000_000)
    )
    private lazy var testData = Self.testData

    // MARK: - OfflineCheckboxState.accessibilityValue

    func test_accessibilityValue_whenChecked() {
        XCTAssertEqual(OfflineCheckboxState.checked.accessibilityValue, "Selected")
    }

    func test_accessibilityValue_whenUnchecked() {
        XCTAssertEqual(OfflineCheckboxState.unchecked.accessibilityValue, "Not selected")
    }

    func test_accessibilityValue_whenPartial() {
        XCTAssertEqual(OfflineCheckboxState.partial.accessibilityValue, "Partially selected")
    }

    // MARK: - selectionState (no sub-items)

    func test_selectionState_withNoSubItems_whenSelected_shouldBeChecked() {
        let testee = makeCourse(isSelected: true, subItems: [])

        XCTAssertEqual(testee.selectionState, .checked)
    }

    func test_selectionState_withNoSubItems_whenNotSelected_shouldBeUnchecked() {
        let testee = makeCourse(isSelected: false, subItems: [])

        XCTAssertEqual(testee.selectionState, .unchecked)
    }

    // MARK: - selectionState (with sub-items)

    func test_selectionState_whenAllSubItemsSelected_shouldBeChecked() {
        let testee = makeCourse(subItems: [
            makeSubItem(id: testData.subItemID1, isSelected: true),
            makeSubItem(id: testData.subItemID2, isSelected: true)
        ])

        XCTAssertEqual(testee.selectionState, .checked)
    }

    func test_selectionState_whenNoSubItemsSelected_shouldBeUnchecked() {
        let testee = makeCourse(subItems: [
            makeSubItem(id: testData.subItemID1, isSelected: false),
            makeSubItem(id: testData.subItemID2, isSelected: false)
        ])

        XCTAssertEqual(testee.selectionState, .unchecked)
    }

    func test_selectionState_whenSomeSubItemsSelected_shouldBePartial() {
        let testee = makeCourse(subItems: [
            makeSubItem(id: testData.subItemID1, isSelected: true),
            makeSubItem(id: testData.subItemID2, isSelected: false),
            makeSubItem(id: testData.subItemID3, isSelected: false)
        ])

        XCTAssertEqual(testee.selectionState, .partial)
    }

    // MARK: - hasSubItems

    func test_hasSubItems_whenSubItemsExist_shouldBeTrue() {
        let testee = makeCourse(subItems: [makeSubItem(id: testData.subItemID1, isSelected: false)])

        XCTAssertEqual(testee.hasSubItems, true)
    }

    func test_hasSubItems_whenNoSubItems_shouldBeFalse() {
        let testee = makeCourse(subItems: [])

        XCTAssertEqual(testee.hasSubItems, false)
    }

    // MARK: - sizeToDownload

    func test_sizeToDownload_withNoSubItems_shouldReturnFallback() {
        let testee = makeCourse(subItems: [])

        XCTAssertEqual(testee.sizeToDownload, 0.0)
    }

    func test_sizeToDownload_withSubItems_shouldReturnSumOfSubItemSizes() {
        let testee = makeCourse(subItems: [
            makeSubItem(id: testData.subItemID1, isSelected: true, sizeInBytes: testData.subItemSizeInBytes1),
            makeSubItem(id: testData.subItemID2, isSelected: true, sizeInBytes: testData.subItemSizeInBytes2)
        ])

        XCTAssertEqual(testee.sizeToDownload, testData.subItemSizeInBytes1 + testData.subItemSizeInBytes2)
    }

    // MARK: - init(from entity)

    func test_initFromEntity_shouldMapBasicProperties() {
        let entity: CDHCourseSelection = databaseClient.insert()
        entity.id = testData.courseID
        entity.name = testData.courseName
        entity.size = testData.courseSize
        entity.files = []

        let testee = OfflineCourseItem(from: entity, offlineSyncItems: [])

        XCTAssertEqual(testee.id, testData.courseID)
        XCTAssertEqual(testee.name, testData.courseName)
        XCTAssertEqual(testee.size, testData.courseSize)
    }

    func test_initFromEntity_shouldDefaultIsExpandedToFalse() {
        let entity: CDHCourseSelection = databaseClient.insert()
        entity.id = testData.courseID
        entity.name = testData.courseName
        entity.size = testData.courseSize
        entity.files = []

        let testee = OfflineCourseItem(from: entity, offlineSyncItems: [])

        XCTAssertEqual(testee.isExpanded, false)
    }

    func test_initFromEntity_shouldDefaultIsSelectedToFalse() {
        let entity: CDHCourseSelection = databaseClient.insert()
        entity.id = testData.courseID
        entity.name = testData.courseName
        entity.size = testData.courseSize
        entity.files = []

        let testee = OfflineCourseItem(from: entity, offlineSyncItems: [])

        XCTAssertEqual(testee.isSelected, false)
    }

    func test_initFromEntity_shouldMapFilesToSubItems() {
        let courseEntity: CDHCourseSelection = databaseClient.insert()
        courseEntity.id = testData.courseID
        courseEntity.name = testData.courseName
        courseEntity.size = testData.courseSize

        let fileEntity: CDHCourseSelectionFile = databaseClient.insert()
        fileEntity.id = testData.subItemID1
        fileEntity.courseID = testData.courseID
        fileEntity.name = "file name 1"
        fileEntity.size = "1 MB"
        fileEntity.sizeInBytes = testData.subItemSizeInBytes1
        courseEntity.files = [fileEntity]

        let testee = OfflineCourseItem(from: courseEntity, offlineSyncItems: [])

        XCTAssertEqual(testee.files.count, 1)
        XCTAssertEqual(testee.files.first?.id, testData.subItemID1)
    }

    func test_initFromEntity_whenCourseSyncedAtCourseLevel_filesNotInSyncItems_shouldMarkFilesSelected() {
        let courseEntity: CDHCourseSelection = databaseClient.insert()
        courseEntity.id = testData.courseID
        courseEntity.name = testData.courseName
        courseEntity.size = testData.courseSize

        let fileEntity: CDHCourseSelectionFile = databaseClient.insert()
        fileEntity.id = testData.subItemID1
        fileEntity.courseID = testData.courseID
        fileEntity.name = "file name 1"
        fileEntity.size = "1 MB"
        fileEntity.sizeInBytes = testData.subItemSizeInBytes1
        courseEntity.files = [fileEntity]

        let fileSyncPath = OfflineType.file(courseID: testData.courseID, fileID: testData.subItemID1).path()
        let courseSyncPath = OfflineType.course(id: testData.courseID).path()
        let testee = OfflineCourseItem(from: courseEntity, offlineSyncItems: [fileSyncPath, courseSyncPath])

        XCTAssertEqual(testee.isSelected, true)
        XCTAssertEqual(testee.files.first?.isSelected, true)
    }

    func test_initFromEntity_whenCourseNotSynced_filesFollowTheirOwnSyncState() {
        let courseEntity: CDHCourseSelection = databaseClient.insert()
        courseEntity.id = testData.courseID
        courseEntity.name = testData.courseName
        courseEntity.size = testData.courseSize

        let fileEntity: CDHCourseSelectionFile = databaseClient.insert()
        fileEntity.id = testData.subItemID1
        fileEntity.courseID = testData.courseID
        fileEntity.name = "file name 1"
        fileEntity.size = "1 MB"
        fileEntity.sizeInBytes = testData.subItemSizeInBytes1
        courseEntity.files = [fileEntity]

        let testee = OfflineCourseItem(from: courseEntity, offlineSyncItems: [])

        XCTAssertEqual(testee.isSelected, false)
        XCTAssertEqual(testee.files.first?.isSelected, false)
    }

    // MARK: - Private helpers

    private func makeCourse(
        isSelected: Bool = false,
        subItems: [OfflineFileItem]
    ) -> OfflineCourseItem {
        OfflineCourseItem(
            id: testData.courseID,
            enrollmentID: "122",
            name: testData.courseName,
            size: testData.courseSize,
            isExpanded: false,
            isSelected: isSelected,
            subItems: subItems
        )
    }

    private func makeSubItem(
        id: String,
        isSelected: Bool,
        sizeInBytes: Double = 1_000_000
    ) -> OfflineFileItem {
        OfflineFileItem(
            id: id,
            name: "sub item name",
            size: "1 MB",
            sizeInBytes: sizeInBytes,
            isSelected: isSelected,
            mimeClass: "pdf",
            courseID: "11"
        )
    }
}
