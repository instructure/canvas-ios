//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import XCTest

class CourseSyncSelectorViewModelItemTests: XCTestCase {
    private var mockInteractor: MockCourseSyncSelectorInteractor!
    private var mockCourseSyncListInteractor: CourseSyncListInteractorMock!

    override func setUp() {
        super.setUp()
        mockCourseSyncListInteractor = CourseSyncListInteractorMock()
        mockInteractor = MockCourseSyncSelectorInteractor(
            courseSyncListInteractor: mockCourseSyncListInteractor,
            sessionDefaults: .fallback
        )
    }

    // MARK: - Properties

    func testHashEquals() {
        let testee1 = CourseSyncSelectorViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       selectionState: .selected,
                                                       cellStyle: .listItem)
        let testee2 = CourseSyncSelectorViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       selectionState: .selected,
                                                       cellStyle: .listItem)
        XCTAssertEqual(testee1, testee2)
        XCTAssertEqual(testee1.hashValue, testee2.hashValue)
    }

    func testIsCollapsed() {
        let testee = CourseSyncSelectorViewModel.Item(id: "",
                                                      title: "",
                                                      subtitle: "",
                                                      selectionState: .selected,
                                                      isCollapsed: true,
                                                      cellStyle: .listAccordionHeader)
        XCTAssertEqual(testee.isCollapsed, true)
    }

    // MARK: - Course

    func testCourseMapping() {
        var data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [])
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "testID")
        XCTAssertEqual(testee.title, "test")
        XCTAssertNil(testee.subtitle)
        XCTAssertTrue(testee.cellStyle == .mainAccordionHeader)

        data.isCollapsed = true
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, true)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, false)
    }

    func testCourseCollapsion() {
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [.init(id: "0", name: "Assignments", type: .assignments)], files: [])

        course.isCollapsed = true
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 1)

        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 2)
    }

    func testExpandedEmptyCourse() {
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [])
        course.isCollapsed = false

        let testee = [course].makeViewModelItems(interactor: mockInteractor)

        XCTAssertEqual(testee.count, 2)

        guard case .item(let item) = testee[0],
              case .empty(let emptyViewId) = testee[1]
        else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "testID")
        XCTAssertEqual(emptyViewId, "course-testID-empty")
    }

    // MARK: - Course Tabs

    func testCourseTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Test", type: .assignments)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.title, "Test")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listAccordionHeader)

        data.selectionState = .selected
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.selectionState == .selected)

        data.selectionState = .deselected
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.selectionState == .selected)
    }

    func testFilesTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Files", type: .files)

        data.isCollapsed = true
        var testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, true)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, false)
    }

    func testFilesTabCollapsion() {
        let file = CourseSyncEntry.File.make(id: "0", displayName: "test.txt")
        var filesTab = CourseSyncEntry.Tab(id: "0", name: "Files", type: .files)

        filesTab.isCollapsed = true
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 2)

        filesTab.isCollapsed = false
        course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 3)
    }

    // MARK: - Files

    func testFileItemMapping() {
        var data = CourseSyncEntry.File.make(id: "1", displayName: "testFile")
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.title, "testFile")
        XCTAssertEqual(testee.subtitle, "Zero KB")
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listItem)

        data.selectionState = .selected
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.selectionState == .selected)

        data.selectionState = .deselected
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.selectionState == .selected)
    }

    // MARK: - Selection

    func testSelectionForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
                                           id: "testID",
                                           tabs: [
                                            .init(id: "0", name: "Assignments", type: .assignments, isCollapsed: false, selectionState: .deselected),
                                            .init(id: "0", name: "Files", type: .files, isCollapsed: false, selectionState: .deselected),
                                           ],
                                           files: [
                                            .make(id: "0", displayName: "test.txt", selectionState: .deselected),
                                            .make(id: "1", displayName: "test1.txt", selectionState: .deselected),
                                           ],
                                           isCollapsed: false,
                                           selectionState: .deselected)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)

        guard case .item(let item0) = testee[0],
              case .item(let item2) = testee[2],
              case .item(let item3) = testee[3]
        else {
            return XCTFail()
        }

        item0.selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.course("testID"))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        item2.selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.tab("testID", "0"))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        item3.selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.file("testID", "0"))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
    }

    // MARK: - Collapsing

    func testCourseCollapseEventForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
                                           id: "testID",
                                           tabs: [
                                            .init(id: "0", name: "Assignments", type: .assignments, isCollapsed: false, selectionState: .deselected),
                                           ],
                                           files: [],
                                           isCollapsed: false,
                                           selectionState: .deselected)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)

        guard case .item(let item) = testee[0] else {
            return XCTFail()
        }

        item.collapseDidToggle?()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.course("testID"))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }

    func testTabCollapseEventForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
                                           id: "testID",
                                           tabs: [
                                            .init(id: "0", name: "Files", type: .files, isCollapsed: false, selectionState: .deselected),
                                           ],
                                           files: [
                                            .make(id: "0", displayName: "test.txt", selectionState: .deselected),
                                           ],
                                           isCollapsed: false,
                                           selectionState: .deselected)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)

        guard case .item(let item) = testee[1] else {
            return XCTFail()
        }

        item.collapseDidToggle?()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.tab("testID", "0"))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }
}

private class MockCourseSyncSelectorInteractor: CourseSyncSelectorInteractor {
    private(set) var lastSelected: (selection: Core.CourseEntrySelection, isSelected: Bool)?
    private(set) var lastCollapsed: (selection: Core.CourseEntrySelection, isCollapsed: Bool)?

    required init(
        courseID: String? = nil,
        courseSyncListInteractor: CourseSyncListInteractor,
        sessionDefaults: SessionDefaults
    ) {}

    func getCourseSyncEntries() -> AnyPublisher<[Core.CourseSyncEntry], Error> {
        Just<[Core.CourseSyncEntry]>([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func observeSelectedCount() -> AnyPublisher<Int, Never> {
        Just<Int>(0)
            .eraseToAnyPublisher()
    }

    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    func setSelected(selection: Core.CourseEntrySelection, selectionState: ListCellView.SelectionState) {
        lastSelected = (selection: selection, isSelected: selectionState == .selected ? true : false)
    }

    func setCollapsed(selection: Core.CourseEntrySelection, isCollapsed: Bool) {
        lastCollapsed = (selection: selection, isCollapsed: isCollapsed)
    }

    func toggleAllCoursesSelection(isSelected: Bool) {}

    func getSelectedCourseEntries() -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        Just<[Core.CourseSyncEntry]>([])
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }

    func getCourseName() -> AnyPublisher<String, Never> {
        Just("").eraseToAnyPublisher()
    }
}
