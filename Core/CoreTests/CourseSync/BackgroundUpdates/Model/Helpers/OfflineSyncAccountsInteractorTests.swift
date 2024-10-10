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

class OfflineSyncAccountsInteractorTests: XCTestCase {

    func testReturnsAccountsWithSyncEnabledAndSyncDateInThePast() {
        let now = Date.now
        var defaults: SessionDefaults!

        let syncDisabledAccount = LoginSession.make(userID: "syncDisabled")
        defaults = SessionDefaults(sessionID: syncDisabledAccount.uniqueID)
        defaults.isOfflineAutoSyncEnabled = false
        defaults.offlineSyncNextDate = .distantPast

        let syncEnabledDateInFutureAccount = LoginSession.make(userID: "syncEnabledDateInFuture")
        defaults = SessionDefaults(sessionID: syncEnabledDateInFutureAccount.uniqueID)
        defaults.isOfflineAutoSyncEnabled = true
        defaults.offlineSyncNextDate = now.addingTimeInterval(1)

        let syncEnabledDateInPastAccount = LoginSession.make(userID: "syncEnabledDateInPast")
        defaults = SessionDefaults(sessionID: syncEnabledDateInPastAccount.uniqueID)
        defaults.isOfflineAutoSyncEnabled = true
        defaults.offlineSyncNextDate = now.addingTimeInterval(-1)

        let syncEnabledDateIsNowAccount = LoginSession.make(userID: "syncEnabledDateIsNow")
        defaults = SessionDefaults(sessionID: syncEnabledDateIsNowAccount.uniqueID)
        defaults.isOfflineAutoSyncEnabled = true
        defaults.offlineSyncNextDate = now

        let sessions = [
            syncDisabledAccount,
            syncEnabledDateInFutureAccount,
            syncEnabledDateInPastAccount,
            syncEnabledDateIsNowAccount
        ]

        // WHEN
        let result = OfflineSyncAccountsInteractor().calculate(sessions, date: now)

        // THEN
        XCTAssertEqual(result, [syncEnabledDateInPastAccount, syncEnabledDateIsNowAccount])
    }
}
