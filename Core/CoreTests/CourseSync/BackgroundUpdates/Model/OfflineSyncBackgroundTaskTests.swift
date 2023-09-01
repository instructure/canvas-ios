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

class OfflineSyncBackgroundTaskTests: XCTestCase {

    func testCalculatesEarliestBeginDateFromLoginSessions() {
        let mockOfflineSyncNextDate = MockOfflineSyncNextDate()

        // WHEN
        let testee = OfflineSyncBackgroundTask(nextSyncDate: mockOfflineSyncNextDate,
                                               sessions: Set([
                                                LoginSession.make(baseURL: URL(string: "https://testURL")!,
                                                                  userID: "testUser"),
                                                LoginSession.make(baseURL: URL(string: "https://testURL2")!,
                                                                  userID: "testUser2"),
                                               ]))

        // THEN
        XCTAssertEqual(mockOfflineSyncNextDate.receivedSessionIDs.sorted(), ["testURL-testUser", "testURL2-testUser2"])
        XCTAssertEqual(testee.request.earliestBeginDate, mockOfflineSyncNextDate.mockDate)
    }
}

private class MockOfflineSyncNextDate: OfflineSyncNextDate {
    let mockDate = Date(timeIntervalSince1970: 3456)
    var receivedSessionIDs: [String] = []

    override func calculate(sessionUniqueIDs: [String]) -> Date? {
        receivedSessionIDs = sessionUniqueIDs
        return mockDate
    }
}
