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

    override func setUp() {
        super.setUp()
        mockInteractor = MockCourseSyncSelectorInteractor()
    }

    // MARK: - Properties

    func testHashEquals() {
        let testee1 = CourseSyncSelectorViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       isSelected: true,
                                                       cellStyle: .listItem)
        let testee2 = CourseSyncSelectorViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       isSelected: true,
                                                       cellStyle: .listItem)
        XCTAssertEqual(testee1, testee2)
        XCTAssertEqual(testee1.hashValue, testee2.hashValue)
    }

    func testIsCollapsed() {
        let testee = CourseSyncSelectorViewModel.Item(id: "",
                                                      title: "",
                                                      subtitle: "",
                                                      isSelected: true,
                                                      isCollapsed: true,
                                                      cellStyle: .listAccordionHeader)
        XCTAssertEqual(testee.isCollapsed, true)
    }

    // MARK: - Course

    func testCourseMapping() {
        var data = CourseSyncSelectorEntry(name: "test", id: "testID", tabs: [], files: [])
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "course-testID")
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
        var course = CourseSyncSelectorEntry(name: "test", id: "testID", tabs: [.init(id: "0", name: "Assignments", type: .assignments)], files: [])

        course.isCollapsed = true
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 1)

        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 2)
    }

    // MARK: - Course Tabs

    func testCourseTabMapping() {
        var data = CourseSyncSelectorEntry.Tab(id: "1", name: "Test", type: .assignments)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "courseTab-1")
        XCTAssertEqual(testee.title, "Test")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listAccordionHeader)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }

    func testFilesTabMapping() {
        var data = CourseSyncSelectorEntry.Tab(id: "1", name: "Files", type: .files)

        data.isCollapsed = true
        var testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, true)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.isCollapsed, false)
    }

    func testFilesTabCollapsion() {
        let file = CourseSyncSelectorEntry.File(id: "0", name: "test.txt", url: nil)
        var filesTab = CourseSyncSelectorEntry.Tab(id: "0", name: "Files", type: .files)

        filesTab.isCollapsed = true
        var course = CourseSyncSelectorEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 2)

        filesTab.isCollapsed = false
        course = CourseSyncSelectorEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 3)
    }

    // MARK: - Files

    func testFileItemMapping() {
        var data = CourseSyncSelectorEntry.File(id: "1", name: "testFile", url: nil)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "file-1")
        XCTAssertEqual(testee.title, "testFile")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listItem)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }

    // MARK: - Selection

    func testSelectionForwardedToInteractor() {
        let data = CourseSyncSelectorEntry(name: "test",
                                   id: "testID",
                                   tabs: [
                                    .init(id: "0", name: "Assignments", type: .assignments, isCollapsed: false, isSelected: false),
                                    .init(id: "0", name: "Files", type: .files, isCollapsed: false, isSelected: false),
                                   ],
                                   files: [
                                    .init(id: "0", name: "test.txt", url: nil, isSelected: false),
                                    .init(id: "1", name: "test1.txt", url: nil, isSelected: false),
                                   ],
                                   isCollapsed: false,
                                   isSelected: false)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)
        testee[0].selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.course(0))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        testee[2].selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.tab(0, 1))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        testee[3].selectionDidToggle?()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.file(0, 0))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
    }

    // MARK: - Collapsing

    func testCourseCollapseEventForwardedToInteractor() {
        let data = CourseSyncSelectorEntry(name: "test",
                                   id: "testID",
                                   tabs: [
                                    .init(id: "0", name: "Assignments", type: .assignments, isCollapsed: false, isSelected: false),
                                   ],
                                   files: [],
                                   isCollapsed: false,
                                   isSelected: false)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)
        testee[0].collapseDidToggle?()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.course(0))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }

    func testTabCollapseEventForwardedToInteractor() {
        let data = CourseSyncSelectorEntry(name: "test",
                                   id: "testID",
                                   tabs: [
                                    .init(id: "0", name: "Files", type: .files, isCollapsed: false, isSelected: false),
                                   ],
                                   files: [
                                    .init(id: "0", name: "test.txt", url: nil, isSelected: false),
                                   ],
                                   isCollapsed: false,
                                   isSelected: false)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)
        testee[1].collapseDidToggle?()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.tab(0, 0))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }
}

private class MockCourseSyncSelectorInteractor: CourseSyncSelectorInteractor {
    private(set) var lastSelected: (selection: Core.CourseEntrySelection, isSelected: Bool)?
    private(set) var lastCollapsed: (selection: Core.CourseEntrySelection, isCollapsed: Bool)?

    func getCourseSyncEntries() -> AnyPublisher<[Core.CourseSyncSelectorEntry], Error> {
        Just<[Core.CourseSyncSelectorEntry]>([])
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

    func setSelected(selection: Core.CourseEntrySelection, isSelected: Bool) {
        lastSelected = (selection: selection, isSelected: isSelected)
    }

    func setCollapsed(selection: Core.CourseEntrySelection, isCollapsed: Bool) {
        lastCollapsed = (selection: selection, isCollapsed: isCollapsed)
    }

    func toggleAllCoursesSelection(isSelected: Bool) {}

    func getSelectedCourseEntries() -> AnyPublisher<[Core.CourseSyncSelectorEntry], Never> {
        Just<[Core.CourseSyncSelectorEntry]>([])
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }
}
