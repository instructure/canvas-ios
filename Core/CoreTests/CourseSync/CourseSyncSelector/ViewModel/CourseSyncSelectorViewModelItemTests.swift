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
                                                       isSelected: true,
                                                       backgroundColor: .white,
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       trailingIcon: .closed,
                                                       isIndented: true)
        let testee2 = CourseSyncSelectorViewModel.Item(id: "",
                                                       isSelected: true,
                                                       backgroundColor: .white,
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       trailingIcon: .closed,
                                                       isIndented: true)
        XCTAssertEqual(testee1, testee2)
        XCTAssertEqual(testee1.hashValue, testee2.hashValue)
    }

    func testIsCollapsed() {
        let testee = CourseSyncSelectorViewModel.Item(id: "",
                                                      isSelected: true,
                                                      backgroundColor: .white,
                                                      title: "",
                                                      subtitle: "",
                                                      trailingIcon: .closed,
                                                      isIndented: true)
        XCTAssertTrue(testee.isCollapsed)
    }

    // MARK: - Course

    func testCourseMapping() {
        var data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [])
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "course-testID")
        XCTAssertTrue(testee.isSelected)
        XCTAssertEqual(testee.backgroundColor, .backgroundLight)
        XCTAssertEqual(testee.title, "test")
        XCTAssertNil(testee.subtitle)
        XCTAssertFalse(testee.isIndented)

        data.isCollapsed = true
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .closed)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .opened)
    }

    func testCourseCollapsion() {
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [.init(id: "0", name: "Assignments", type: .assignments)], files: [])

        course.isCollapsed = true
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 1)

        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems(interactor: mockInteractor).count, 2)
    }

    // MARK: - Course Tabs

    func testCourseTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Test", type: .assignments)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "courseTab-1")
        XCTAssertEqual(testee.backgroundColor, .backgroundLightest)
        XCTAssertEqual(testee.title, "Test")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.trailingIcon, .none)
        XCTAssertFalse(testee.isIndented)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }

    func testFilesTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Files", type: .files)

        data.isCollapsed = true
        var testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .closed)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .opened)
    }

    func testFilesTabCollapsion() {
        let file = CourseSyncEntry.File(id: "0", name: "test.txt", url: nil)
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
        var data = CourseSyncEntry.File(id: "1", name: "testFile", url: nil)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.id, "file-1")
        XCTAssertEqual(testee.backgroundColor, .backgroundLightest)
        XCTAssertEqual(testee.title, "testFile")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.trailingIcon, .none)
        XCTAssertTrue(testee.isIndented)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }

    // MARK: - Selection

    func testSelectionForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
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
        testee[0].selectionToggled()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.course(0))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        testee[2].selectionToggled()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.tab(0, 1))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
        testee[3].selectionToggled()
        XCTAssertEqual(mockInteractor.lastSelected?.selection, CourseEntrySelection.file(0, 0))
        XCTAssertEqual(mockInteractor.lastSelected?.isSelected, true)
    }

    // MARK: - Collapsing

    func testCourseCollapseEventForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
                                   id: "testID",
                                   tabs: [
                                    .init(id: "0", name: "Assignments", type: .assignments, isCollapsed: false, isSelected: false),
                                   ],
                                   files: [],
                                   isCollapsed: false,
                                   isSelected: false)
        let testee = [data].makeViewModelItems(interactor: mockInteractor)
        testee[0].collapseToggled()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.course(0))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }

    func testTabCollapseEventForwardedToInteractor() {
        let data = CourseSyncEntry(name: "test",
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
        testee[1].collapseToggled()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.tab(0, 0))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }
}

private class MockCourseSyncSelectorInteractor: CourseSyncSelectorInteractor {
    private(set) var lastSelected: (selection: Core.CourseEntrySelection, isSelected: Bool)?
    private(set) var lastCollapsed: (selection: Core.CourseEntrySelection, isCollapsed: Bool)?

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

    func setSelected(selection: Core.CourseEntrySelection, isSelected: Bool) {
        lastSelected = (selection: selection, isSelected: isSelected)
    }

    func setCollapsed(selection: Core.CourseEntrySelection, isCollapsed: Bool) {
        lastCollapsed = (selection: selection, isCollapsed: isCollapsed)
    }

    func toggleAllCoursesSelection(isSelected: Bool) {}
}
