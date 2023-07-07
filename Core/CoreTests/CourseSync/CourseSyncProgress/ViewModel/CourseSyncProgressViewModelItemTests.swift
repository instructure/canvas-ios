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

class CourseSyncProgressViewModelItemTests: XCTestCase {
    private var mockInteractor: MockCourseSyncProgressInteractor!

    override func setUp() {
        super.setUp()
        mockInteractor = MockCourseSyncProgressInteractor()
    }

    // MARK: - Properties

    func testHashEquals() {
        let testee1 = CourseSyncProgressViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       cellStyle: .listItem,
                                                       state: .downloaded)
        let testee2 = CourseSyncProgressViewModel.Item(id: "",
                                                       title: "testTitle",
                                                       subtitle: "subTitle",
                                                       cellStyle: .listItem,
                                                       state: .downloaded)
        XCTAssertEqual(testee1, testee2)
        XCTAssertEqual(testee1.hashValue, testee2.hashValue)
    }

    func testIsCollapsed() {
        let testee = CourseSyncProgressViewModel.Item(id: "",
                                                      title: "",
                                                      subtitle: "",
                                                      isCollapsed: true,
                                                      cellStyle: .listAccordionHeader,
                                                      state: .downloaded)
        XCTAssertEqual(testee.isCollapsed, true)
    }

    func testState() {
        var data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [], state: .downloaded)
        var testee = data.makeSyncProgressViewModelItem()
        XCTAssertEqual(testee.state, .downloaded)

        data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [], state: .error)
        testee = data.makeSyncProgressViewModelItem()
        XCTAssertEqual(testee.state, .error)

        data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [], state: .loading(0.123))
        testee = data.makeSyncProgressViewModelItem()
        XCTAssertEqual(testee.state, .loading(0.123))
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
        XCTAssertEqual([course].makeSyncProgressViewModelItems(interactor: mockInteractor).count, 1)

        course.isCollapsed = false
        XCTAssertEqual([course].makeSyncProgressViewModelItems(interactor: mockInteractor).count, 2)
    }

    func testExpandedEmptyCourse() {
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [])
        course.isCollapsed = false

        let testee = [course].makeSyncProgressViewModelItems(interactor: mockInteractor)

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
        var testee = data.makeSyncProgressViewModelItem()

        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.title, "Test")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listAccordionHeader)

        data.selectionState = .selected
        testee = data.makeSyncProgressViewModelItem()

        data.selectionState = .deselected
        testee = data.makeSyncProgressViewModelItem()
    }

    func testFilesTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Files", type: .files)

        data.isCollapsed = true
        var testee = data.makeSyncProgressViewModelItem()
        XCTAssertEqual(testee.isCollapsed, true)

        data.isCollapsed = false
        testee = data.makeSyncProgressViewModelItem()
        XCTAssertEqual(testee.isCollapsed, false)
    }

    func testFilesTabCollapsion() {
        let file = CourseSyncEntry.File.make(id: "0", displayName: "test.txt")
        var filesTab = CourseSyncEntry.Tab(id: "0", name: "Files", type: .files)

        filesTab.isCollapsed = true
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        XCTAssertEqual([course].makeSyncProgressViewModelItems(interactor: mockInteractor).count, 2)

        filesTab.isCollapsed = false
        course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        course.isCollapsed = false
        XCTAssertEqual([course].makeSyncProgressViewModelItems(interactor: mockInteractor).count, 3)
    }

    // MARK: - Files

    func testFileItemMapping() {
        var data = CourseSyncEntry.File.make(id: "1", displayName: "testFile")
        var testee = data.makeSyncProgressViewModelItem()

        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.title, "testFile")
        XCTAssertEqual(testee.subtitle, "Zero KB")
        XCTAssertEqual(testee.isCollapsed, nil)
        XCTAssertTrue(testee.cellStyle == .listItem)

        data.selectionState = .selected
        testee = data.makeSyncProgressViewModelItem()

        data.selectionState = .deselected
        testee = data.makeSyncProgressViewModelItem()
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
        let testee = [data].makeSyncProgressViewModelItems(interactor: mockInteractor)

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
        let testee = [data].makeSyncProgressViewModelItems(interactor: mockInteractor)

        guard case .item(let item) = testee[1] else {
            return XCTFail()
        }

        item.collapseDidToggle?()
        XCTAssertEqual(mockInteractor.lastCollapsed?.selection, CourseEntrySelection.tab("testID", "0"))
        XCTAssertEqual(mockInteractor.lastCollapsed?.isCollapsed, true)
    }
}

class MockCourseSyncProgressInteractor: CourseSyncProgressInteractor {
    let courseSyncEntriesSubject = PassthroughSubject<[CourseSyncEntry], Error>()
    let courseSyncFileProgressSubject = PassthroughSubject<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never>()

    func observeDownloadProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        courseSyncFileProgressSubject.eraseToAnyPublisher()
    }

    func setProgress(selection: Core.CourseEntrySelection, progress: Float?) {
    }

    func cancelSync() {
    }

    func retrySync() {
    }

    func remove(selection: Core.CourseEntrySelection) {
    }

    private(set) var lastSelected: (selection: Core.CourseEntrySelection, isSelected: Bool)?
    private(set) var lastCollapsed: (selection: Core.CourseEntrySelection, isCollapsed: Bool)?

    required init(courseID: String? = nil) {
    }

    func observeEntries() -> AnyPublisher<[Core.CourseSyncEntry], Error> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }

    func setCollapsed(selection: Core.CourseEntrySelection, isCollapsed: Bool) {
        lastCollapsed = (selection: selection, isCollapsed: isCollapsed)
    }

    func getCourseName() -> AnyPublisher<String, Never> {
        Just("").eraseToAnyPublisher()
    }
}
