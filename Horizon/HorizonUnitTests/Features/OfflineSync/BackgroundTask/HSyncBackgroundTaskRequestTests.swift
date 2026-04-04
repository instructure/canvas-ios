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

final class HSyncBackgroundTaskRequestTests: XCTestCase {

    private let session1 = LoginSession.make(baseURL: URL(string: "https://testurl.com")!, userID: "user-1")
    private let session2 = LoginSession.make(baseURL: URL(string: "https://testurl2.com")!, userID: "user-2")

    // MARK: - Properties

    func test_properties() {
        let testee = HSyncBackgroundTaskRequest(
            nextSyncDate: MockHSyncNextDateInteractor(),
            sessions: Set()
        )!

        XCTAssertEqual(testee.requiresNetworkConnectivity, true)
        XCTAssertEqual(testee.requiresExternalPower, false)
    }

    // MARK: - Begin date

    func test_earliestBeginDate_shouldBeCalculatedFromSessions() {
        let mock = MockHSyncNextDateInteractor()

        let testee = HSyncBackgroundTaskRequest(
            nextSyncDate: mock,
            sessions: Set([session1, session2])
        )!

        XCTAssertEqual(mock.receivedSessionIDs.sorted(), ["testurl.com-user-1", "testurl2.com-user-2"])
        XCTAssertEqual(testee.earliestBeginDate, mock.mockedDate)
    }

    func test_init_whenNoBeginDateAvailable_shouldReturnNil() {
        let mock = MockHSyncNextDateInteractor()
        mock.mockedDate = nil

        let testee = HSyncBackgroundTaskRequest(
            nextSyncDate: mock,
            sessions: Set([session1, session2])
        )

        XCTAssertNil(testee)
    }
}

// MARK: - Mocks

private class MockHSyncNextDateInteractor: HSyncNextDateInteractor {
    var mockedDate: Date? = Date(timeIntervalSince1970: 3456)
    var receivedSessionIDs: [String] = []

    override func calculate(sessionUniqueIDs: [String]) -> Date? {
        receivedSessionIDs = sessionUniqueIDs
        return mockedDate
    }
}
