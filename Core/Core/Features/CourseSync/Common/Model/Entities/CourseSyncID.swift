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

import Foundation

public struct CourseSyncID {
    let value: String
    let apiBaseURL: URL?

    var localID: String { value.localID }

    var targetEnvironment: AppEnvironment {
        .resolved(for: apiBaseURL)
    }

    var sessionId: String {
        targetEnvironment.currentSession?.uniqueID ?? ""
    }

    var offlineURL: URL {
        URL
            .Paths
            .Offline
            .rootURL(sessionID: sessionId)
    }

    var studioOfflineURL: URL {
        offlineURL.appendingPathComponent("studio", isDirectory: true)
    }

    var asContext: Context {
        .course(localID)
    }
}
