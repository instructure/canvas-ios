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
                                        hasFrontPage: false,
                                        tabs: [.init(id: "", name: "", type: .assignments)],
                                        files: [])

    // MARK: - Scheduling Related Tests

    func testSchedulesNextBackgroundSyncWhenFinishedCurrentSync() {
        let mockScheduler = MockSyncScheduler()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler,
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)))

        // WHEN
        testee.start {}

        // THEN
        XCTAssertTrue(mockScheduler.scheduleNextSyncInvoked)
    }

    func testSchedulesNextBackgroundSyncWhenCancelled() {
        let mockScheduler = MockSyncScheduler()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler,
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)))

        // WHEN
        testee.cancel()

        // THEN
        XCTAssertTrue(mockScheduler.scheduleNextSyncInvoked)
    }

    func testUpdatesNextSyncDateForSyncCompletedUser() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let mockScheduler = MockSyncScheduler()
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               syncScheduler: mockScheduler,
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)),
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
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)),
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
        XCTAssertNil(mockSelectedItems.receivedCourseID)
        XCTAssertEqual(mockSyncInteractor.receivedEntries, [mockSyncEntry])
        waitForExpectations(timeout: 1)
    }

    /// We simulate that `getCourseSyncEntries` takes a long time so we can interrupt the sync with cancel.
    func testCancelsDownload() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let neverPubliser = PassthroughSubject<[CourseSyncEntry], Never>().eraseToAnyPublisher()
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: neverPubliser)
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]),
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)),
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

    func testCompletesIfThereAreNoAccountsToSync() {
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([.make()]))
        let completed = expectation(description: "Task completed")

        // WHEN
        testee.start { completed.fulfill() }

        // THEN
        waitForExpectations(timeout: 5)
    }

    func testIteratesThroughUsersAndRestoresLastLoggedInOneUponFinish() {
        let user1 = LoginSession.make(userID: "1")
        let user2 = LoginSession.make(userID: "2")
        AppEnvironment.shared.userDidLogin(session: user1)
        mockSyncAccountsCalculator.accounts = [user1, user2]
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([user1, user2]),
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.wifi)),
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

    func testSkipsSyncIfWifiOnlySelectedButNoWifiAvailable() {
        mockSyncAccountsCalculator.accounts = [.make()]
        let session: LoginSession = .make()
        var sessionDefaults = SessionDefaults(sessionID: session.uniqueID)
        sessionDefaults.isOfflineWifiOnlySyncEnabled = true
        let mockSelectedItems = MockSelectedItemsFactory(mockSyncEntries: Just([mockSyncEntry]).eraseToAnyPublisher())
        let mockSyncInteractor = MockCourseSyncInteractor()
        let testee = OfflineSyncBackgroundTask(syncableAccounts: mockSyncAccountsCalculator,
                                               sessions: Set<LoginSession>([session]),
                                               networkAvailabilityService: networkAvailabilityMock(.connected(.cellular)),
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
        XCTAssertFalse(mockSelectedItems.getCelectedCourseEntriesInvoked)
        XCTAssertNil(mockSyncInteractor.receivedEntries)
        XCTAssertEqual(mockSyncInteractor.downloadContentInvocationCount, 0)
        waitForExpectations(timeout: 1)
    }

    // MARK: - Private Helpers

    private func mockFinishedDownload() {
        NotificationCenter.default.post(name: .OfflineSyncCompleted, object: nil)
    }

    private func networkAvailabilityMock(_ status: NetworkAvailabilityStatus) -> NetworkAvailabilityService {
        let monitor = NWPathMonitorWrapper(start: { _ in () }, cancel: {})
        let networkAvailabilityService = NetworkAvailabilityServiceLive(monitor: monitor)
        let path: NWPathWrapper

        switch status {
        case .connected(let connectionType):
            path = NWPathWrapper(status: .satisfied, isExpensive: connectionType == .cellular ? true : false)
        case .disconnected:
            path = NWPathWrapper(status: .unsatisfied, isExpensive: false)
        }
        monitor.updateHandler?(path)
        return networkAvailabilityService
    }
}

private class MockOfflineSyncAccountsInteractor: OfflineSyncAccountsInteractor {
    var accounts: [LoginSession] = []

    override func calculate(_ sessions: [LoginSession], date: Date) -> [LoginSession] {
        accounts
    }
}

private class MockSelectedItemsFactory: CourseSyncSelectorInteractorMock {
    var mockSyncEntries: AnyPublisher<[CourseSyncEntry], Never>
    private(set) var receivedCourseID: String?
    private(set) var getCelectedCourseEntriesInvoked = false

    init(mockSyncEntries: AnyPublisher<[CourseSyncEntry], Never>) {
        self.mockSyncEntries = mockSyncEntries
        super.init(courseID: "",
                   courseSyncListInteractor: CourseSyncListInteractorMock(),
                   sessionDefaults: .fallback)
    }

    required init(courseID: String? = nil,
                  courseSyncListInteractor: CourseSyncListInteractor,
                  sessionDefaults: SessionDefaults) {
        self.mockSyncEntries = Empty<[CourseSyncEntry], Never>().eraseToAnyPublisher()
        super.init(courseID: "",
                   courseSyncListInteractor: CourseSyncListInteractorMock(),
                   sessionDefaults: .fallback)
    }

    override func getCourseSyncEntries() -> AnyPublisher<[Core.CourseSyncEntry], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    override func getSelectedCourseEntries() -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        getCelectedCourseEntriesInvoked = true
        return mockSyncEntries
    }
}

private class MockCourseSyncInteractor: CourseSyncInteractor {
    private(set) var isCancelCalled = false
    private(set) var receivedEntries: [CourseSyncEntry]?
    private(set) var downloadContentInvocationCount = 0
    private(set) var receivedCoursesToClean: [String]?
    private(set) var cleanContentInvocationCount = 0

    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[Core.CourseSyncEntry], Never> {
        receivedEntries = entries
        downloadContentInvocationCount += 1
        return Just([]).eraseToAnyPublisher()
    }

    func cleanContent(for courseIds: [String]) -> AnyPublisher<Void, Never> {
        receivedCoursesToClean = courseIds
        cleanContentInvocationCount += 1
        return Just(()).eraseToAnyPublisher()
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
