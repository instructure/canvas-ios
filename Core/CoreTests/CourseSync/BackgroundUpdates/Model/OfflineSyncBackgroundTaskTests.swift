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
import Combine
import TestsFoundation
import XCTest

class OfflineSyncBackgroundTaskTests: CoreTestCase {
    private let mockSyncAccountsCalculator = MockOfflineSyncAccountsInteractor()
    let mockSyncEntry = CourseSyncEntry(name: "",
                                        id: "",
                                        tabs: [.init(id: "", name: "", type: .assignments)],
                                        files: [])

    func testCompletesIfThereAreNoAccountsToSync() {
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]))
        let completed = expectation(description: "Task completed")

        // WHEN
        testee.start { completed.fulfill() }

        // THEN
        waitForExpectations(timeout: 1)
    }

    // MARK: - Scheduling Related Tests

    func testSchedulesNextBackgroundSyncWhenFinishedCurrentSync() {
        let mockScheduler = MockSyncScheduler()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler)

        // WHEN
        testee.start {}

        // THEN
        XCTAssertTrue(mockScheduler.scheduleNextSyncInvoked)
    }

    func testSchedulesNextBackgroundSyncWhenCancelled() {
        let mockScheduler = MockSyncScheduler()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler)

        // WHEN
        testee.cancel()

        // THEN
        XCTAssertTrue(mockScheduler.scheduleNextSyncInvoked)
    }

    func testUpdatesNextSyncDateForSyncCompletedUser() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let mockScheduler = MockSyncScheduler()
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).setFailureType(to: Error.self).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler,
                                               selectedItemsInteractorFactory: { _ in
                                                   mockSelectedItems
                                               },
                                               syncInteractorFactory: {
                                                    mockSyncInteractor
                                               })
        let completed = expectation(description: "Sync completed")

        // WHEN
        testee.start { completed.fulfill() }
        mockFinishedDownload()

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockScheduler.syncNextDateSessionUniqueID, "canvas.instructure.com-1")
    }

    // MARK: -

    func testDownloadsSelectedSyncEntries() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).setFailureType(to: Error.self).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               selectedItemsInteractorFactory: { _ in
                                                   mockSelectedItems
                                               },
                                               syncInteractorFactory: {
                                                    mockSyncInteractor
                                               })
        let completed = expectation(description: "Sync completed")

        // WHEN
        testee.start { completed.fulfill() }
        mockFinishedDownload()

        // THEN
        XCTAssertEqual(mockSelectedItems.receivedFilter, .all)
        XCTAssertEqual(mockSyncInteractor.receivedEntries, [mockSyncEntry])
        waitForExpectations(timeout: 1)
    }

    /// We simulate that `getCourseSyncEntries` takes a long time so we can interrput the sync with cancel.
    func testCancelsDownload() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let neverPubliser = PassthroughSubject<[CourseSyncEntry], Error>().eraseToAnyPublisher()
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: neverPubliser)
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               selectedItemsInteractorFactory: { _ in
                                                   mockSelectedItems
                                               },
                                               syncInteractorFactory: {
                                                    mockSyncInteractor
                                               })

        // WHEN
        testee.start {}
        testee.cancel()

        // THEN
        XCTAssertNil(mockSyncInteractor.receivedEntries)
    }

    func testIteratesThroughUsersAndRestoresLastLoggedInOneUponFinish() {
        let user1 = LoginSession.make(userID: "1")
        let user2 = LoginSession.make(userID: "2")
        AppEnvironment.shared.userDidLogin(session: user1)
        mockSyncAccountsCalculator.accounts = [user1, user2]
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).setFailureType(to: Error.self).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([user1, user2]),
                                               selectedItemsInteractorFactory: { _ in
                                                   mockSelectedItems
                                               },
                                               syncInteractorFactory: {
                                                    mockSyncInteractor
                                               })
        let completed = expectation(description: "Sync completed")

        // WHEN
        testee.start { completed.fulfill() }

        // THEN
        waitUntil {
            mockSyncInteractor.downloadContentInvocationCount == 1
        }
        XCTAssertEqual(AppEnvironment.shared.currentSession, user1)
        mockFinishedDownload()
        waitUntil {
            mockSyncInteractor.downloadContentInvocationCount == 2
        }
        XCTAssertEqual(AppEnvironment.shared.currentSession, user2)
        mockFinishedDownload()
        XCTAssertEqual(mockSyncInteractor.downloadContentInvocationCount, 2)
        waitForExpectations(timeout: 1)
        XCTAssertEqual(AppEnvironment.shared.currentSession, user1)
    }

    private func mockFinishedDownload() {
        let progress: CDCourseSyncDownloadProgress = AppEnvironment.shared.database.viewContext.insert()
        progress.isFinished = true
    }
}

private class MockOfflineSyncAccountsInteractor: OfflineSyncAccountsInteractor {
    var accounts: [LoginSession] = []

    override func calculate(_ sessions: [LoginSession], date: Date) -> [LoginSession] {
        accounts
    }
}

private class MockSelectedItemsFactory: CourseSyncListInteractor {
    var mockSyncEntries: AnyPublisher<[CourseSyncEntry], Error>
    private(set) var receivedFilter: CourseSyncListFilter?

    init(mockSyncEntries: AnyPublisher<[CourseSyncEntry], Error>) {
        self.mockSyncEntries = mockSyncEntries
    }

    func getCourseSyncEntries(filter: CourseSyncListFilter) -> AnyPublisher<[CourseSyncEntry], Error> {
        receivedFilter = filter
        return mockSyncEntries
    }
}

private class MockCourseSyncInteractor: CourseSyncInteractor {
    private(set) var isCancelCalled = false
    private(set) var receivedEntries: [CourseSyncEntry]?
    private(set) var downloadContentInvocationCount = 0

    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        receivedEntries = entries
        downloadContentInvocationCount += 1
        return Just([]).eraseToAnyPublisher()
    }

    func cancel() {
        isCancelCalled = true
    }
}

private class MockSyncScheduler: OfflineSyncScheduleInteractor {
    private(set) var scheduleNextSyncInvoked = false
    private(set) var syncNextDateSessionUniqueID: String?

    override func scheduleNextSync() {
        scheduleNextSyncInvoked = true
    }

    override func updateNextSyncDate(sessionUniqueID: String) {
        syncNextDateSessionUniqueID = sessionUniqueID
    }
}
