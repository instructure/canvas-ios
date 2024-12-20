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
import XCTest

class OfflineSyncBackgroundTaskRequestTests: XCTestCase {
    private let session1 = LoginSession.make(baseURL: URL(string: "https://testURL")!,
                                             userID: "testUser")
    private let session2 = LoginSession.make(baseURL: URL(string: "https://testURL2")!,
                                             userID: "testUser2")

    func testProperties() {
        let nextDateCalculator = MockOfflineSyncNextDateInteractor()

        // WHEN
        let testee = OfflineSyncBackgroundTaskRequest(nextSyncDate: nextDateCalculator,
                                                      sessions: Set())!

        // THEN
        XCTAssertFalse(testee.requiresExternalPower)
        XCTAssertTrue(testee.requiresNetworkConnectivity)
    }

    func testCalculatesEarliestBeginDateFromLoginSessions() {
        let mockOfflineSyncNextDate = MockOfflineSyncNextDateInteractor()

        // WHEN
        let testee = OfflineSyncBackgroundTaskRequest(nextSyncDate: mockOfflineSyncNextDate,
                                                      sessions: Set([session1, session2]))!

        // THEN
        XCTAssertEqual(mockOfflineSyncNextDate.receivedSessionIDs.sorted(), ["testURL-testUser", "testURL2-testUser2"])
        XCTAssertEqual(testee.earliestBeginDate, mockOfflineSyncNextDate.mockedDate)
    }

    func testNotInitalizesIfThereIsNoBeginDate() {
        let mockOfflineSyncNextDate = MockOfflineSyncNextDateInteractor()
        mockOfflineSyncNextDate.mockedDate = nil

        // WHEN
        let testee = OfflineSyncBackgroundTaskRequest(nextSyncDate: mockOfflineSyncNextDate,
                                                      sessions: Set([session1, session2]))

        // THEN
        XCTAssertNil(testee)
    }
}

class MockOfflineSyncNextDateInteractor: OfflineSyncNextDateInteractor {
    var mockedDate: Date? = Date(timeIntervalSince1970: 3456)
    var receivedSessionIDs: [String] = []

    override func calculate(sessionUniqueIDs: [String]) -> Date? {
        receivedSessionIDs = sessionUniqueIDs
        return mockedDate
    }
}
