//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation

final class PendoManagerMock: PendoManagerWrapper {

    // MARK: - initWith

    var initWithUrlCallsCount: Int = 0
    var initWithUrlInput: URL?

    func initWith(_ url: URL) {
        initWithUrlInput = url
        initWithUrlCallsCount += 1
    }

    // MARK: - setup

    var setupCallsCount: Int = 0
    var setupInput: String?

    func setup(_ appKey: String) {
        setupInput = appKey
        setupCallsCount += 1
    }

    // MARK: - startSession

    var startSessionCallsCount: Int = 0
    var startSessionInput: (
        visitorId: String?,
        accountId: String?,
        visitorData: [AnyHashable: Any]?,
        accountData: [AnyHashable: Any]?
    )?

    func startSession(
        _ visitorId: String?,
        accountId: String?,
        visitorData: [AnyHashable: Any]?,
        accountData: [AnyHashable: Any]?
    ) {
        startSessionInput = (visitorId, accountId, visitorData, accountData)
        startSessionCallsCount += 1
    }

    // MARK: - endSession

    var endSessionCallsCount: Int = 0

    func endSession() {
        endSessionCallsCount += 1
    }

    // MARK: - track

    var trackCallsCount: Int = 0
    var trackInput: (event: String, properties: [AnyHashable: Any]?)?

    func track(_ event: String, properties: [AnyHashable: Any]?) {
        trackInput = (event, properties)
        trackCallsCount += 1
    }
}
