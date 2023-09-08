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
import BackgroundTasks

struct CoreTaskSchedulerLive: CoreBGTaskScheduler {
    private let taskScheduler: BGTaskScheduler

    init(taskScheduler: BGTaskScheduler) {
        self.taskScheduler = taskScheduler
    }

    func register(forTaskWithIdentifier identifier: String,
                  using queue: DispatchQueue?,
                  launchHandler: @escaping (CoreBGTask) -> Void)
    -> Bool {
        taskScheduler.register(forTaskWithIdentifier: identifier,
                               using: queue,
                               launchHandler: launchHandler)
    }

    func cancel(taskRequestWithIdentifier identifier: String) {
        taskScheduler.cancel(taskRequestWithIdentifier: identifier)
    }

    func submit(_ request: BGTaskRequest) throws {
        try taskScheduler.submit(request)
    }
}
