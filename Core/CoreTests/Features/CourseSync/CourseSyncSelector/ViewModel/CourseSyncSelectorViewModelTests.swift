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
        XCTAssertFalse(testee.leftNavBarButtonVisible)
        XCTAssertFalse(testee.isShowingSyncConfirmationDialog)
    }

    func testSyncConfirmAlertProps() {
        XCTAssertEqual(testee.syncConfirmAlert.title, "Sync Offline Content?")
        XCTAssertEqual(testee.syncConfirmAlert.cancelButtonTitle, "Cancel")
        XCTAssertEqual(testee.syncConfirmAlert.confirmButtonTitle, "Sync")
        XCTAssertNil(testee.syncConfirmAlert.confirmButtonRole)
    }

    func testCancelConfirmAlertProps() {
        XCTAssertEqual(testee.cancelConfirmAlert.title, "Cancel Offline Content Sync?")
        XCTAssertEqual(testee.cancelConfirmAlert.message, "Selection changes that you may had made won't be saved. Are you sure you want to cancel?")
        XCTAssertEqual(testee.cancelConfirmAlert.cancelButtonTitle, "No")
        XCTAssertEqual(testee.cancelConfirmAlert.confirmButtonTitle, "Yes")
        XCTAssertEqual(testee.cancelConfirmAlert.confirmButtonRole, .destructive)
    }

    func testUpdateSelectAllButtonTitle() {
        mockSelectorInteractor.isEverythingSelectedSubject.send(true)
        XCTAssertEqual(testee.leftNavBarTitle, "Deselect All")

        mockSelectorInteractor.isEverythingSelectedSubject.send(false)
        XCTAssertEqual(testee.leftNavBarTitle, "Select All")
    }

    func testUpdateConfirmationDialogMessage() {
        mockSelectorInteractor.selectedSizeSubject.send(1024)
        XCTAssertEqual(testee.syncConfirmAlert.message, "This will sync ~1 KB content. It may result in additional charges from your data provider if you are not connected to a Wi-Fi network.")
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
        XCTAssertTrue(testee.isShowingSyncConfirmationDialog)

        let expectation = expectation(description: "Publisher sends value.")
        let subsription = mockSelectorInteractor
            .saveSelectionSubject
            .sink(receiveValue: {
                expectation.fulfill()
            })
        testee.syncConfirmAlert.notifyCompletion(isConfirmed: true)
        waitForExpectations(timeout: 0.1)
        subsription.cancel()
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
                                       hasFrontPage: false,
                                       tabs: [],
                                       files: [])
        mockSelectorInteractor.courseSyncEntriesSubject.send([mockItem])
        waitUntil(shouldFail: true) {
            testee.state == .data
        }
        XCTAssertEqual(testee.cells.count, 1)
        XCTAssertTrue(testee.leftNavBarButtonVisible)

        guard case let .item(item) = testee.cells[0] else {
            return XCTFail()
        }

        XCTAssertEqual(item.id, "test")
    }

    func testUpdatesNavBarSubtitle() {
        XCTAssertEqual(testee.navBarSubtitle, "Test Name")
    }

    func testCancelTapInLoadingState() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        XCTAssertEqual(testee.state, .loading)

        // WHEN
        testee.cancelButtonDidTap.accept(weakController)

        // THEN
        XCTAssertEqual(testee.isShowingCancelConfirmationDialog, false)
        XCTAssertEqual(router.dismissed, controller)
    }

    func testCancelTapInErrorState() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        mockSelectorInteractor.courseSyncEntriesSubject.send(
            completion: .failure(NSError.internalError())
        )
        waitUntil(1, shouldFail: true) {
            testee.state == .error
        }

        // WHEN
        testee.cancelButtonDidTap.accept(weakController)

        // THEN
        XCTAssertEqual(testee.isShowingCancelConfirmationDialog, false)
        XCTAssertEqual(router.dismissed, controller)
    }

    func testCancelTapInDataState() {
        let controller = UIViewController()
        let weakController = WeakViewController(controller)
        mockSelectorInteractor.courseSyncEntriesSubject.send([])

        waitUntil(1, shouldFail: true) {
            testee.state == .data
        }

        // WHEN
        testee.cancelButtonDidTap.accept(weakController)

        // THEN
        XCTAssertEqual(testee.isShowingCancelConfirmationDialog, true)
        XCTAssertEqual(router.dismissed, nil)

        // WHEN
        testee.cancelConfirmAlert.notifyCompletion(isConfirmed: true)

        // THEN
        XCTAssertEqual(router.dismissed, controller)
    }

    func testLogsSyncButtonTap() {
        let mockAnalytics = MockAnalyticsHandler()
        Analytics.shared.handler = mockAnalytics

        // WHEN
        testee.syncButtonDidTap.accept(.init(UIViewController()))

        // THEN
        XCTAssertEqual(mockAnalytics.lastEvent, "offline_sync_button_tapped")
        XCTAssertEqual(mockAnalytics.totalEventCount, 1)
    }
}

class CourseSyncSelectorInteractorMock: CourseSyncSelectorInteractor {
    required init(
        courseID _: String? = nil,
        courseSyncListInteractor _: CourseSyncListInteractor,
        sessionDefaults _: SessionDefaults
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

    let getDeselectedCourseIdsSubject = PassthroughSubject<[String], Never>()
    func getDeselectedCourseIds() -> AnyPublisher<[String], Never> {
        getDeselectedCourseIdsSubject.eraseToAnyPublisher()
    }

    let selectedCountSubject = PassthroughSubject<Int, Never>()
    func observeSelectedCount() -> AnyPublisher<Int, Never> {
        selectedCountSubject.eraseToAnyPublisher()
    }

    let selectedSizeSubject = PassthroughSubject<Int, Never>()
    func observeSelectedSize() -> AnyPublisher<Int, Never> {
        selectedSizeSubject.eraseToAnyPublisher()
    }

    func setSelected(selection _: Core.CourseEntrySelection, selectionState _: OfflineListCellView.SelectionState) {}

    let saveSelectionSubject = PassthroughSubject<Void, Never>()
    func saveSelection() {
        saveSelectionSubject.send(())
    }
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
    let courseSyncCleanSubject = PassthroughSubject<Void, Never>()

    func downloadContent(for _: [Core.CourseSyncEntry]) -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        courseSyncEntriesSubject.eraseToAnyPublisher()
    }

    func cleanContent(for _: [String]) -> AnyPublisher<Void, Never> {
        courseSyncCleanSubject.eraseToAnyPublisher()
    }

    func cancel() {}
}

class CourseSyncListInteractorMock: CourseSyncListInteractor {
    let courseSyncEntrySubject = PassthroughSubject<[CourseSyncEntry], Error>()

    func getCourseSyncEntries(filter _: CourseSyncListFilter) -> AnyPublisher<[CourseSyncEntry], Error> {
        courseSyncEntrySubject.eraseToAnyPublisher()
    }
}

class CourseSyncEntryComposerInteractorMock: CourseSyncEntryComposerInteractor {
    let courseSyncEntrySubject = PassthroughSubject<CourseSyncEntry, Error>()

    func composeEntry(from _: Core.CourseSyncSelectorCourse, useCache _: Bool) -> AnyPublisher<Core.CourseSyncEntry, Error> {
        courseSyncEntrySubject.eraseToAnyPublisher()
    }
}
