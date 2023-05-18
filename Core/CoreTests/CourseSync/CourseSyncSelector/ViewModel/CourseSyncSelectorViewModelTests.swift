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
import TestsFoundation
import XCTest

class CourseSyncSelectorViewModelTests: XCTestCase {
    var testee: CourseSyncSelectorViewModel!
    var mockSelectorInteractor: CourseSyncSelectorInteractorMock!
    var mockSyncInteractor: CourseSyncInteractorMock!

    override func setUp() {
        super.setUp()
        mockSelectorInteractor = CourseSyncSelectorInteractorMock()
        mockSyncInteractor = CourseSyncInteractorMock()
        testee = CourseSyncSelectorViewModel(
            selectorInteractor: mockSelectorInteractor,
            syncInteractor: mockSyncInteractor
        )
    }

    func testInitialState() {
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.items, [])
        XCTAssertTrue(testee.syncButtonDisabled)
        XCTAssertFalse(testee.leftNavBarButtonVisible)
        XCTAssertFalse(testee.isShowingConfirmationDialog)
    }

    func testConfirmAlertProps() {
        XCTAssertEqual(testee.confirmAlert.title, "Sync Offline Content?")
        XCTAssertEqual(testee.confirmAlert.cancelButtonTitle, "Cancel")
        XCTAssertEqual(testee.confirmAlert.confirmButtonTitle, "Sync")
        XCTAssertNil(testee.confirmAlert.confirmButtonRole)
    }

    func testUpdateSyncButtonState() {
        mockSelectorInteractor.selectedCountSubject.send(0)
        XCTAssertTrue(testee.syncButtonDisabled)

        mockSelectorInteractor.selectedCountSubject.send(5)
        XCTAssertFalse(testee.syncButtonDisabled)
    }

    func testUpdateSelectAllButtonTitle() {
        mockSelectorInteractor.isEverythingSelectedSubject.send(true)
        XCTAssertEqual(testee.leftNavBarTitle, "Deselect All")

        mockSelectorInteractor.isEverythingSelectedSubject.send(false)
        XCTAssertEqual(testee.leftNavBarTitle, "Select All")
    }

    func testUpdateConfirmationDialogMessage() {
        mockSelectorInteractor.selectedCountSubject.send(3)
        XCTAssertEqual(testee.confirmAlert.message, "There are 3 items selected for offline availability. The selected content will be downloaded to the device.")
    }

    func testLeftNavBarTap() {
        testee.leftNavBarButtonDidTap.accept()
        mockSelectorInteractor.isEverythingSelectedSubject.send(true)
        XCTAssertEqual(mockSelectorInteractor.toggleAllCoursesSelectionParam, false)

        testee.leftNavBarButtonDidTap.accept()
        mockSelectorInteractor.isEverythingSelectedSubject.send(false)
        XCTAssertEqual(mockSelectorInteractor.toggleAllCoursesSelectionParam, true)
    }

    func testSyncButtonTap() {
        testee.syncButtonDidTap.accept(WeakViewController(UIViewController()))
        XCTAssertTrue(testee.isShowingConfirmationDialog)
    }

    func testUpdateStateFails() {
        mockSelectorInteractor.courseSyncEntriesSubject.send(completion: .failure(NSError.instructureError("Failed")))
        waitUntil(shouldFail: true) {
            testee.state == .error
        }
    }

    func testUpdateStateSucceeds() {
        let mockItem = CourseSyncSelectorEntry(name: "",
                                               id: "test",
                                               tabs: [],
                                               files: [])
        mockSelectorInteractor.courseSyncEntriesSubject.send([mockItem])
        waitUntil(shouldFail: true) {
            testee.state == .data
        }
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items[0].id, "course-test")
        XCTAssertTrue(testee.leftNavBarButtonVisible)
    }
}

class CourseSyncSelectorInteractorMock: CourseSyncSelectorInteractor {

    required init(courseID: String? = nil) {
    }

    let courseSyncEntriesSubject = PassthroughSubject<[CourseSyncSelectorEntry], Error>()
    func getCourseSyncEntries() -> AnyPublisher<[Core.CourseSyncSelectorEntry], Error> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }

    let isEverythingSelectedSubject = PassthroughSubject<Bool, Never>()
    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        isEverythingSelectedSubject.eraseToAnyPublisher()
    }

    let getSelectedCourseEntriesSubject = PassthroughSubject<[Core.CourseSyncSelectorEntry], Never>()
    func getSelectedCourseEntries() -> AnyPublisher<[Core.CourseSyncSelectorEntry], Never> {
        getSelectedCourseEntriesSubject.eraseToAnyPublisher()
    }

    let selectedCountSubject = PassthroughSubject<Int, Never>()
    func observeSelectedCount() -> AnyPublisher<Int, Never> {
        selectedCountSubject.eraseToAnyPublisher()
    }

    func setSelected(selection _: Core.CourseEntrySelection, selectionState _: ListCellView.SelectionState) {}
    func setCollapsed(selection _: Core.CourseEntrySelection, isCollapsed _: Bool) {}

    var toggleAllCoursesSelectionParam: Bool?
    func toggleAllCoursesSelection(isSelected: Bool) {
        toggleAllCoursesSelectionParam = isSelected
    }
}

class CourseSyncInteractorMock: CourseSyncInteractor {
    let courseSyncEntriesSubject = PassthroughSubject<[CourseSyncSelectorEntry], Error>()

    func downloadContent(for _: [Core.CourseSyncSelectorEntry]) -> AnyPublisher<[Core.CourseSyncSelectorEntry], Error> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }
}
