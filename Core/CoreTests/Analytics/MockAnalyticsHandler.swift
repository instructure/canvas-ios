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

import Core

class MockAnalyticsHandler: AnalyticsHandler {
    var lastEvent: String?
    var lastEventParameters: [String: Any]?
    var totalEventCount = 0

    var lastErrorName: String?
    var lastErrorReason: String?
    var totalErrorCount = 0

    var lastScreenName: String?
    var lastScreenClass: String?
    var lastScreenViewApp: String?
    var totalScreenViewCount = 0

    func handleScreenView(screenName: String, screenClass: String, application: String) {
        lastScreenName = screenName
        lastScreenClass = screenClass
        lastScreenViewApp = application
        totalScreenViewCount += 1
    }

    func handleError(_ name: String, reason: String) {
        lastErrorName = name
        lastErrorReason = reason
        totalErrorCount += 1
    }

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        lastEvent = name
        lastEventParameters = parameters
        totalEventCount += 1
    }
}
