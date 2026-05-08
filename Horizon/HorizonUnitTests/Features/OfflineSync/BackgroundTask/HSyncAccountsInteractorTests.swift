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

final class HSyncAccountsInteractorTests: XCTestCase {

    private let disabledSession = LoginSession.make(userID: "disabled")
    private let futureDateSession = LoginSession.make(userID: "future-date")
    private let pastDateSession = LoginSession.make(userID: "past-date")
    private let nowDateSession = LoginSession.make(userID: "now-date")

    override func tearDown() {
        [disabledSession, futureDateSession, pastDateSession, nowDateSession].forEach {
            var defaults = SessionDefaults(sessionID: $0.uniqueID)
            defaults.reset()
        }
        super.tearDown()
    }

    func test_calculate_shouldReturnSessionsWithSyncEnabledAndSyncDateNotInFuture() {
        let now = Date.now

        var defaults = SessionDefaults(sessionID: disabledSession.uniqueID)
        defaults.isHorizonAutoSyncEnabled = false
        defaults.horizonSyncNextDate = .distantPast

        defaults = SessionDefaults(sessionID: futureDateSession.uniqueID)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonSyncNextDate = now.addingTimeInterval(1)

        defaults = SessionDefaults(sessionID: pastDateSession.uniqueID)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonSyncNextDate = now.addingTimeInterval(-1)

        defaults = SessionDefaults(sessionID: nowDateSession.uniqueID)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonSyncNextDate = now

        let result = HSyncAccountsInteractorLive().calculate(
            [disabledSession, futureDateSession, pastDateSession, nowDateSession],
            date: now
        )

        XCTAssertEqual(result, [pastDateSession, nowDateSession])
    }
}
