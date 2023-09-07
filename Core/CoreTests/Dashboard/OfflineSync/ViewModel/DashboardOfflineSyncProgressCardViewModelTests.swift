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

@testable import Core
import CoreData
import Combine
import CombineSchedulers
import XCTest

class DashboardOfflineSyncProgressCardViewModelTests: CoreTestCase {

    func testSubtitleItemCounterIgnoresContainerSelections() {
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               router: router,
                                                               scheduler: .immediate)
        XCTAssertEqual(testee.subtitle, "2 items are syncing.")
    }

    func testAppearsWhenReceivingSyncStartNotification() {
        // MARK: - GIVEN
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               router: router)
        XCTAssertFalse(testee.isVisible)

        // MARK: - WHEN
        NotificationCenter.default.post(name: .OfflineSyncTriggered,
                                        object: nil)

        // MARK: - THEN
        XCTAssertTrue(testee.isVisible)
    }

    func testDismissesItselfDelayedWhenProgressReaches1() {
        // MARK: - GIVEN
        let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient,
                                                                      progressToReport: 1)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               router: router,
                                                               scheduler: testScheduler.eraseToAnyScheduler())
        NotificationCenter.default.post(name: .OfflineSyncTriggered,
                                        object: nil)
        XCTAssertTrue(testee.isVisible)

        // MARK: - WHEN
        testScheduler.advance(by: .seconds(0.9))
        XCTAssertTrue(testee.isVisible)
        testScheduler.advance(by: .seconds(0.1))

        // MARK: - THEN
        XCTAssertFalse(testee.isVisible)
    }

    func testUpdatesProgress() {
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               router: router,
                                                               scheduler: .immediate)

        XCTAssertEqual(testee.progress, 0.5)
    }

    func testDismissHidesCard() {
        // MARK: - GIVEN
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
                                                               router: router)
        NotificationCenter.default.post(name: .OfflineSyncTriggered,
                                        object: nil)
        XCTAssertTrue(testee.isVisible)

        // MARK: - WHEN
        testee.dismissDidTap.accept()

        // MARK: - THEN
        XCTAssertFalse(testee.isVisible)
    }

    func testCardTapRoutesToProgressView() {
        // MARK: - GIVEN
        let mockInteractor = CourseSyncProgressObserverInteractorMock(context: databaseClient)
        let testee = DashboardOfflineSyncProgressCardViewModel(interactor: mockInteractor,
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

    init(context: NSManagedObjectContext, progressToReport: Float = 0.5) {
        self.context = context
        self.progressToReport = progressToReport
    }

    func observeDownloadProgress()
    -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        let item: CourseSyncDownloadProgress = context.insert()
        item.bytesToDownload = Int(bytesToDownload)
        item.bytesDownloaded = Int(progressToReport * bytesToDownload)
        return Just(.data([item])).eraseToAnyPublisher()
    }

    func observeStateProgress()
    -> AnyPublisher<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never> {
        let course: CourseSyncStateProgress = context.insert()
        course.selection = .course("")
        let fileTab: CourseSyncStateProgress = context.insert()
        fileTab.selection = .tab("", "courses/123/tabs/files")
        let file1: CourseSyncStateProgress = context.insert()
        file1.selection = .file("", "")
        let file2: CourseSyncStateProgress = context.insert()
        file2.selection = .file("", "")

        return Just(.data([course, fileTab, file1, file2])).eraseToAnyPublisher()
    }
}
