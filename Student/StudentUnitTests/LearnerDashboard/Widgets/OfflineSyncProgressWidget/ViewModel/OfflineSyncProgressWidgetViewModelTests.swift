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

import Combine
@testable import Core
@testable import Student
import TestsFoundation
import XCTest

final class OfflineSyncProgressWidgetViewModelTests: StudentTestCase {

    private var testee: OfflineSyncProgressWidgetViewModel!
    private var dashboardViewModel: DashboardOfflineSyncProgressCardViewModel!
    private var progressObserver: CourseSyncProgressObserverInteractorMock!
    private var progressWriter: CourseSyncProgressWriterInteractorMock!

    override func setUp() {
        super.setUp()
        progressObserver = CourseSyncProgressObserverInteractorMock()
        progressWriter = CourseSyncProgressWriterInteractorMock()
        dashboardViewModel = DashboardOfflineSyncProgressCardViewModel(
            progressObserverInteractor: progressObserver,
            progressWriterInteractor: progressWriter,
            offlineModeInteractor: OfflineModeInteractorMock(mockIsFeatureFlagEnabled: true),
            router: router
        )
    }

    override func tearDown() {
        testee = nil
        dashboardViewModel = nil
        progressObserver = nil
        progressWriter = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInit_setsInitialState() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.progress, 0)
        XCTAssertEqual(testee.progressText, "")
        XCTAssertNil(testee.title)
        XCTAssertNil(testee.subtitleText)
    }

    func testInit_subscribesToDashboardViewModel() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        // Initial state should be .hidden which maps to .empty
        XCTAssertEqual(testee.state, .empty)
    }

    // MARK: - State Mapping

    func testStateMapping_hiddenMapsToEmpty() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        dashboardViewModel.objectWillChange.send()
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.progress, 0)
        XCTAssertEqual(testee.progressText, "")
        XCTAssertNil(testee.title)
        XCTAssertNil(testee.subtitleText)
    }

    // MARK: - Dismiss

    func testDismiss_callsDashboardViewModelDismiss() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        let expectation = expectation(description: "dismiss called")
        let subscription = dashboardViewModel.dismissDidTap.sink { _ in
            expectation.fulfill()
        }

        testee.dismiss()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    // MARK: - Card Tap

    func testCardTapped_callsDashboardViewModelCardTap() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        let viewController = UIViewController()
        let expectation = expectation(description: "cardTap called")
        let subscription = dashboardViewModel.cardDidTap.sink { _ in
            expectation.fulfill()
        }

        testee.cardTapped(viewController: WeakViewController(viewController))

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    // MARK: - Protocol Conformance

    func testIsFullWidth_returnsTrue() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        XCTAssertEqual(testee.isFullWidth, true)
    }

    func testIsEditable_returnsFalse() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        XCTAssertEqual(testee.isEditable, false)
    }

    func testRefresh_returnsImmediately() {
        testee = OfflineSyncProgressWidgetViewModel(
            config: .init(id: .offlineSyncProgress, order: 1, isVisible: true),
            dashboardViewModel: dashboardViewModel
        )

        let expectation = expectation(description: "refresh completes")
        let subscription = testee.refresh(ignoreCache: true).sink {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }
}

private final class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        Empty().eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<[CourseSyncStateProgress], Never> {
        Empty().eraseToAnyPublisher()
    }
}

private final class CourseSyncProgressWriterInteractorMock: CourseSyncProgressWriterInteractor {
    func saveDownloadProgress(entries: [CourseSyncEntry]) {}
    func saveDownloadResult(isFinished: Bool, error: String?) {}
    func cleanUpPreviousDownloadProgress() {}
    func markInProgressDownloadsAsFailed() {}
    func setInitialLoadingState(entries: [CourseSyncEntry]) {}
    func saveStateProgress(id: String, selection: CourseEntrySelection, state: CourseSyncEntry.State) {}
}
