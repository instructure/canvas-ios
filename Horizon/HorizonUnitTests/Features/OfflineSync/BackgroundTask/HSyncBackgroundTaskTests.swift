//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Horizon
import XCTest
import Combine

final class HSyncBackgroundTaskTests: HorizonTestCase {

    private var mockAccountsInteractor: MockHSyncAccountsInteractor!
    private var mockScheduleInteractor: MockHSyncScheduleInteractor!
    private var mockCourseSyncInteractor: HCourseSyncInteractorMock!
    private var mockNetworkService: MockNetworkAvailabilityService!

    override func setUp() {
        super.setUp()
        mockAccountsInteractor = MockHSyncAccountsInteractor()
        mockScheduleInteractor = MockHSyncScheduleInteractor()
        mockCourseSyncInteractor = HCourseSyncInteractorMock()
        mockNetworkService = MockNetworkAvailabilityService()
    }

    override func tearDown() {
        mockAccountsInteractor = nil
        mockScheduleInteractor = nil
        mockCourseSyncInteractor = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - Scheduling

    func test_start_schedulesNextSyncOnCompletion() {
        let testee = makeTask()

        testee.start {}

        XCTAssertEqual(mockScheduleInteractor.scheduleNextSyncCallCount, 1)
    }

    func test_cancel_schedulesNextSync() {
        let testee = makeTask()

        testee.cancel()

        XCTAssertEqual(mockScheduleInteractor.scheduleNextSyncCallCount, 1)
    }

    // MARK: - Session flow

    func test_start_completesWhenNoAccountsToSync() {
        var completionCalled = false
        let testee = makeTask()

        testee.start { completionCalled = true }

        XCTAssertEqual(completionCalled, true)
    }

    func test_start_restoresLastLoggedInSessionOnCompletion() {
        let originalSession = LoginSession.make(userID: "original")
        AppEnvironment.shared.userDidLogin(session: originalSession)
        let testee = makeTask()

        testee.start {}

        XCTAssertEqual(AppEnvironment.shared.currentSession, originalSession)
    }

    func test_cancel_restoresLastLoggedInSession() {
        let originalSession = LoginSession.make(userID: "original")
        AppEnvironment.shared.userDidLogin(session: originalSession)
        let testee = makeTask()

        testee.cancel()

        XCTAssertEqual(AppEnvironment.shared.currentSession, originalSession)
    }

    // MARK: - Private helpers

    private func makeTask() -> HSyncBackgroundTask {
        HSyncBackgroundTask(
            syncableAccounts: mockAccountsInteractor,
            sessions: [],
            scheduleInteractor: mockScheduleInteractor,
            networkAvailabilityService: mockNetworkService,
            courseSyncInteractor: mockCourseSyncInteractor
        )
    }
}

// MARK: - Mocks

private final class MockHSyncAccountsInteractor: HSyncAccountsInteractor {
    var sessionsToReturn: [LoginSession] = []

    func calculate(_ sessions: [LoginSession], date: Date) -> [LoginSession] {
        sessionsToReturn
    }
}

private final class MockHSyncScheduleInteractor: HSyncScheduleInteractor {
    var scheduleNextSyncCallCount = 0
    var updatedSessionIDs: [String] = []

    func scheduleNextSync() {
        scheduleNextSyncCallCount += 1
    }

    func updateNextSyncDate(sessionUniqueID: String) {
        updatedSessionIDs.append(sessionUniqueID)
    }
}

private final class MockNetworkAvailabilityService: NetworkAvailabilityService {
    private let statusSubject = CurrentValueSubject<NetworkAvailabilityStatus?, Never>(.connected(.wifi))

    var status: NetworkAvailabilityStatus? { statusSubject.value }

    func startMonitoring() {}
    func stopMonitoring() {}

    func startObservingStatus() -> CurrentValueSubject<NetworkAvailabilityStatus?, Never> {
        statusSubject
    }
}
