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

public struct BackgroundProcessingInteractor {
    private let scheduler: CoreTaskScheduler

    public init(scheduler: CoreTaskScheduler) {
        self.scheduler = scheduler
    }

    public func register(task: BackgroundTask) {
        let result = scheduler.register(forTaskWithIdentifier: task.request.identifier, using: nil) { backgroundTask in
            backgroundTask.expirationHandler = {
                Logger.shared.error("BackgroundProcessingInteractor: Background task \(task.request.identifier) will be cancelled.")
                task.cancel()
            }
            task.start {
                backgroundTask.setTaskCompleted(success: true)
            }
        }

        if !result {
            Logger.shared.error("BackgroundProcessingInteractor: Failed to register background task \(task.request.identifier).")
        }
    }

    public func schedule(task: BackgroundTask) {
        do {
            try scheduler.submit(task.request)
        } catch(let error) {
            Logger.shared.error("BackgroundProcessingInteractor: Error scheduling task \(task.request.identifier): \(error.localizedDescription)")
        }
    }

    public func cancel(task: BackgroundTask) {
        scheduler.cancel(taskRequestWithIdentifier: task.request.identifier)
    }
}
