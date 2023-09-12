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

        let progress: CourseSyncDownloadProgressEntity = databaseClient.insert()
        progress.bytesToDownload = 1000
        progress.bytesDownloaded = 100
        progress.isFinished = false
        progress.error = nil

        // MARK: - WHEN

        NotificationCenter.default.post(name: .OfflineSyncTriggered, object: nil)
        mockInteractor.mockStateProgress()

        // MARK: - THEN

        mockInteractor.mockDownloadProgress(progress)
        XCTAssertEqual(testee.state, .progress(0.1, "2 items are syncing."))

        progress.bytesDownloaded = 500
        mockInteractor.mockDownloadProgress(progress)
        XCTAssertEqual(testee.state, .progress(0.5, "2 items are syncing."))

        progress.bytesDownloaded = 750
        mockInteractor.mockDownloadProgress(progress)
        XCTAssertEqual(testee.state, .progress(0.75, "2 items are syncing."))

        progress.bytesDownloaded = 1000
        mockInteractor.mockDownloadProgress(progress)
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

    private let downloadProgressPublisher = PassthroughSubject<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never>()
    private let stateProgressPublisher = PassthroughSubject<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never>()

    private lazy var downloadProgressMock: CourseSyncDownloadProgressEntity = {
        let item: CourseSyncDownloadProgressEntity = context.insert()
        item.bytesToDownload = Int(bytesToDownload)
        item.bytesDownloaded = Int(progressToReport * bytesToDownload)
        item.isFinished = false
        item.error = nil
        return item
    }()

    private lazy var downloadProgressFinishedMock: CourseSyncDownloadProgressEntity = {
        let item: CourseSyncDownloadProgressEntity = context.insert()
        item.bytesToDownload = Int(bytesToDownload)
        item.bytesDownloaded = Int(progressToReport * bytesToDownload)
        item.isFinished = true
        item.error = nil
        return item
    }()

    private lazy var downloadProgressErrorMock: CourseSyncDownloadProgressEntity = {
        let item: CourseSyncDownloadProgressEntity = context.insert()
        item.bytesToDownload = Int(bytesToDownload)
        item.bytesDownloaded = Int(progressToReport * bytesToDownload)
        item.isFinished = true
        item.error = "Failed."
        return item
    }()

    private lazy var stateProgressMock: [CourseSyncStateProgressEntity] = {
        let course: CourseSyncStateProgressEntity = context.insert()
        course.selection = .course("")
        let fileTab: CourseSyncStateProgressEntity = context.insert()
        fileTab.selection = .tab("", "courses/123/tabs/files")
        let file1: CourseSyncStateProgressEntity = context.insert()
        file1.selection = .file("", "")
        let file2: CourseSyncStateProgressEntity = context.insert()
        file2.selection = .file("", "")
        return [course, fileTab, file1, file2]
    }()

    init(context: NSManagedObjectContext, progressToReport: Float = 0.5) {
        self.context = context
        self.progressToReport = progressToReport
    }

    func observeDownloadProgress()
        -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        downloadProgressPublisher.eraseToAnyPublisher()
    }

    func observeStateProgress()
        -> AnyPublisher<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never> {
        stateProgressPublisher.eraseToAnyPublisher()
    }

    func mockDownloadProgress() {
        downloadProgressPublisher.send(.data([downloadProgressMock]))
    }

    func mockDownloadProgress(_ progress: CourseSyncDownloadProgressEntity) {
        downloadProgressPublisher.send(.data([progress]))
    }

    func mockFinishedDownloadProgress() {
        downloadProgressPublisher.send(.data([downloadProgressFinishedMock]))
    }

    func mockFailedDownloadProgress() {
        downloadProgressPublisher.send(.data([downloadProgressErrorMock]))
    }

    func mockStateProgress() {
        stateProgressPublisher.send(.data(stateProgressMock))
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
}
