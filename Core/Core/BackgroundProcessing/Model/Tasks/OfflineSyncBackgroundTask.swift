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

import BackgroundTasks

public struct OfflineSyncBackgroundTask: BackgroundTask {
    public let identifier: String
    public let request: BGProcessingTaskRequest

    public init() {
        let id = "com.instructure.icanvas.Core.offline-sync"
        identifier = id
        request = BGProcessingTaskRequest(identifier: id)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = .now.addDays(1)
    }

    public func start(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { completion() }
    }

    public func cancel() {
    }
}
