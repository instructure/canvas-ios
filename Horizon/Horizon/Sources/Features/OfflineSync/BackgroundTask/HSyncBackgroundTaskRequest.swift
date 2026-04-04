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

import BackgroundTasks
import Core

public final class HSyncBackgroundTaskRequest: BGProcessingTaskRequest {
    public static let ID = "com.instructure.icanvas.horizon-sync"

    public init?(nextSyncDate: HSyncNextDateInteractor, sessions: Set<LoginSession>) {
        guard let date = nextSyncDate.calculate(sessionUniqueIDs: sessions.map { $0.uniqueID }) else {
            return nil
        }
        super.init(identifier: Self.ID)
        requiresNetworkConnectivity = true
        requiresExternalPower = false
        earliestBeginDate = date
    }
}
