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
import CombineSchedulers
@testable import Core
import CoreData
import XCTest

class DashboardOfflineSyncProgressCardViewModelTests: CoreTestCase {
    func testSubtitleItemCounterIgnoresContainerSelections() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: .immediate)

        // MARK: - WHEN

        NotificationCenter.default.post(name: .OfflineSyncTriggered, object: nil)
        mockInteractor.mockDownloadProgress()
        mockInteractor.mockStateProgress()

        // MARK: - THEN

        XCTAssertEqual(testee.state, .progress(0.5, "2 items are syncing."))
    }

    func testProgressUpdates() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: .immediate)

        // MARK: - WHEN

        NotificationCenter.default.post(name: .OfflineSyncTriggered, object: nil)
        mockInteractor.mockStateProgress()

        // MARK: - THEN

        mockInteractor.mockDownloadProgress(
            CourseSyncDownloadProgress(
                bytesToDownload: 1000,
                bytesDownloaded: 100,
                isFinished: false,
                error: nil
            )
        )
        XCTAssertEqual(testee.state, .progress(0.1, "2 items are syncing."))

        mockInteractor.mockDownloadProgress(
            CourseSyncDownloadProgress(
                bytesToDownload: 1000,
                bytesDownloaded: 500,
                isFinished: false,
                error: nil
            )
        )
        XCTAssertEqual(testee.state, .progress(0.5, "2 items are syncing."))

        mockInteractor.mockDownloadProgress(
            CourseSyncDownloadProgress(
                bytesToDownload: 1000,
                bytesDownloaded: 750,
                isFinished: false,
                error: nil
            )
        )
        XCTAssertEqual(testee.state, .progress(0.75, "2 items are syncing."))

        mockInteractor.mockDownloadProgress(
            CourseSyncDownloadProgress(
                bytesToDownload: 1000,
                bytesDownloaded: 1000,
                isFinished: false,
                error: nil
            )
        )
        XCTAssertEqual(testee.state, .progress(1, "2 items are syncing."))
    }

    func testErrorState() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: .immediate)

        // MARK: - WHEN

        NotificationCenter.default.post(name: .OfflineSyncTriggered, object: nil)
        mockInteractor.mockFailedDownloadProgress()
        mockInteractor.mockStateProgress()

        // MARK: - THEN

        XCTAssertEqual(testee.state, .error)
    }

    func testAutoDismissOnComplete() {
        // MARK: - GIVEN

        let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient,
                                                                      progressToReport: 1)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: testScheduler.eraseToAnyScheduler())

        // MARK: - WHEN

        NotificationCenter.default.post(
            name: .OfflineSyncTriggered,
            object: nil
        )
        mockInteractor.mockFinishedDownloadProgress()
        mockInteractor.mockStateProgress()

        testScheduler.advance(by: .seconds(0.1))
        XCTAssertFalse(testee.state.isHidden)

        // MARK: - THEN

        testScheduler.advance(by: .seconds(0.9))
        XCTAssertTrue(testee.state.isHidden)
    }

    func testAutoDismissOnCancellation() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient,
                                                                      progressToReport: 1)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: .immediate)

        // MARK: - WHEN

        NotificationCenter.default.post(
            name: .OfflineSyncTriggered,
            object: nil
        )
        mockInteractor.mockDownloadProgress()
        mockInteractor.mockStateProgress()

        XCTAssertFalse(testee.state.isHidden)

        // MARK: - THEN

        NotificationCenter.default.post(
            name: .OfflineSyncCancelled,
            object: nil
        )
        XCTAssertTrue(testee.state.isHidden)
    }

    func testDismissHidesCard() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router,
                                                               scheduler: .immediate)
        NotificationCenter.default.post(name: .OfflineSyncTriggered,
                                        object: nil)
        mockInteractor.mockDownloadProgress()
        mockInteractor.mockStateProgress()
        XCTAssertFalse(testee.state.isHidden)

        // MARK: - WHEN

        testee.dismissDidTap.accept()

        // MARK: - THEN

        XCTAssertTrue(testee.state.isHidden)
    }

    func testCardTapRoutesToProgressView() {
        // MARK: - GIVEN

        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               offlineModeInteractor: MockOfflineModeInteractorEnabled(),
                                                               router: router)
        let source = UIViewController()

        // MARK: - WHEN

        testee.cardDidTap.accept(.init(source))

        // MARK: - THEN

        XCTAssertTrue(router.lastRoutedTo("/offline/progress",
                                          withOptions: .modal(isDismissable: false,
                                                              embedInNav: true)))
    }
}

private class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    private let context: NSManagedObjectContext
    private let progressToReport: Float
    private let bytesToDownload: Float = 10

    private let downloadProgressPublisher = PassthroughSubject<CourseSyncDownloadProgress, Never>()
    private let stateProgressPublisher = PassthroughSubject<[CourseSyncStateProgress], Never>()

    private lazy var downloadProgressMock = CourseSyncDownloadProgress(
        bytesToDownload: Int(bytesToDownload),
        bytesDownloaded: Int(progressToReport * bytesToDownload),
        isFinished: false,
        error: nil
    )

    private lazy var downloadProgressFinishedMock = CourseSyncDownloadProgress(
        bytesToDownload: Int(bytesToDownload),
        bytesDownloaded: Int(progressToReport * bytesToDownload),
        isFinished: true,
        error: nil
    )

    private lazy var downloadProgressErrorMock = CourseSyncDownloadProgress(
        bytesToDownload: Int(bytesToDownload),
        bytesDownloaded: Int(progressToReport * bytesToDownload),
        isFinished: true,
        error: "Failed."
    )

    private lazy var stateProgressMock: [CourseSyncStateProgress] = {
        let course = CourseSyncStateProgress.make(selection: .course(""))
        let fileTab = CourseSyncStateProgress.make(selection: .tab("", "courses/123/tabs/files"))
        let file1 = CourseSyncStateProgress.make(selection: .file("", ""))
        let file2 = CourseSyncStateProgress.make(selection: .file("", ""))
        return [course, fileTab, file1, file2]
    }()

    init(context: NSManagedObjectContext, progressToReport: Float = 0.5) {
        self.context = context
        self.progressToReport = progressToReport
    }

    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        downloadProgressPublisher.eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<[CourseSyncStateProgress], Never> {
        stateProgressPublisher.eraseToAnyPublisher()
    }

    func mockDownloadProgress() {
        downloadProgressPublisher.send(downloadProgressMock)
    }

    func mockDownloadProgress(_ progress: CourseSyncDownloadProgress) {
        downloadProgressPublisher.send(progress)
    }

    func mockFinishedDownloadProgress() {
        downloadProgressPublisher.send(downloadProgressFinishedMock)
    }

    func mockFailedDownloadProgress() {
        downloadProgressPublisher.send(downloadProgressErrorMock)
    }

    func mockStateProgress() {
        stateProgressPublisher.send(stateProgressMock)
    }
}

private class MockOfflineModeInteractorEnabled: OfflineModeInteractor {
    func isFeatureFlagEnabled() -> Bool {
        true
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
        Just(.disconnected).eraseToAnyPublisher()
    }

    func isOfflineModeEnabled() -> Bool { true }

    func isNetworkOffline() -> Bool { true }
}
