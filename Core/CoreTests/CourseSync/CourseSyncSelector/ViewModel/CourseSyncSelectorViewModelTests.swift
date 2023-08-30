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
    var mockListInteractor: CourseSyncListInteractorMock!
    var router: TestRouter!

    override func setUp() {
        super.setUp()
        mockListInteractor = CourseSyncListInteractorMock()
        mockSelectorInteractor = CourseSyncSelectorInteractorMock(
            courseSyncListInteractor: mockListInteractor,
            sessionDefaults: .fallback
        )
        mockSyncInteractor = CourseSyncInteractorMock()
        router = TestRouter()
        testee = CourseSyncSelectorViewModel(
            selectorInteractor: mockSelectorInteractor,
            syncInteractor: mockSyncInteractor,
            router: router
        )
    }

    func testInitialState() {
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.cells, [])
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
        let mockItem = CourseSyncEntry(name: "",
                                               id: "test",
                                               tabs: [],
                                               files: [])
        mockSelectorInteractor.courseSyncEntriesSubject.send([mockItem])
        waitUntil(shouldFail: true) {
            testee.state == .data
        }
        XCTAssertEqual(testee.cells.count, 1)
        XCTAssertTrue(testee.leftNavBarButtonVisible)

        guard case .item(let item) = testee.cells[0] else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "test")
    }

    func testUpdatesNavBarSubtitle() {
        XCTAssertEqual(testee.navBarSubtitle, "Test Name")
    }

    func testCancelTap() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        testee.cancelButtonDidTap.accept(weakController)
        XCTAssertEqual(router.dismissed, controller)
    }
}

class CourseSyncSelectorInteractorMock: CourseSyncSelectorInteractor {
    required init(
        courseID: String? = nil,
        courseSyncListInteractor: CourseSyncListInteractor,
        sessionDefaults: SessionDefaults
    ) {}

    let courseSyncEntriesSubject = PassthroughSubject<[CourseSyncEntry], Error>()
    func getCourseSyncEntries() -> AnyPublisher<[Core.CourseSyncEntry], Error> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }

    let isEverythingSelectedSubject = PassthroughSubject<Bool, Never>()
    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        isEverythingSelectedSubject.eraseToAnyPublisher()
    }

    let getSelectedCourseEntriesSubject = PassthroughSubject<[Core.CourseSyncEntry], Never>()
    func getSelectedCourseEntries() -> AnyPublisher<[Core.CourseSyncEntry], Never> {
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

    func getCourseName() -> AnyPublisher<String, Never> {
        Just("Test Name").eraseToAnyPublisher()
    }
}

class CourseSyncInteractorMock: CourseSyncInteractor {
    let courseSyncEntriesSubject = PassthroughSubject<[CourseSyncEntry], Never>()

    func downloadContent(for _: [Core.CourseSyncEntry]) -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }
}

class CourseSyncListInteractorMock: CourseSyncListInteractor {
    let courseSyncEntrySubject = PassthroughSubject<[CourseSyncEntry], Error>()

    func getCourseSyncEntries(filter: CourseSyncListFilter) -> AnyPublisher<[CourseSyncEntry], Error> {
        courseSyncEntrySubject.eraseToAnyPublisher()
    }
}

class CourseSyncEntryComposerInteractorMock: CourseSyncEntryComposerInteractor {
    let courseSyncEntrySubject = PassthroughSubject<CourseSyncEntry, Error>()

    func composeEntry(from course: Core.CourseSyncSelectorCourse, useCache: Bool) -> AnyPublisher<Core.CourseSyncEntry, Error> {
        courseSyncEntrySubject.eraseToAnyPublisher()
    }
}
