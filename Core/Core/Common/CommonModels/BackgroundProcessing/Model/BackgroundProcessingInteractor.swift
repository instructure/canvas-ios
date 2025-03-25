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
    private let scheduler: CoreBGTaskScheduler
    private static var ElapsedTimeFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()

    public init(scheduler: CoreBGTaskScheduler) {
        self.scheduler = scheduler
    }

    public func register(taskID: String) {
        let isRegistered = scheduler.register(forTaskWithIdentifier: taskID,
                                              using: nil) { backgroundTask in
            guard let task = BackgroundProcessingAssembly.resolveTask(for: backgroundTask.identifier) else {
                RemoteLogger.shared.logError(name: "Background task ID \(taskID) couldn't be resolved to a task.")
                backgroundTask.setTaskCompleted(success: true)
                return
            }

            let startTime = Date()

            backgroundTask.expirationHandler = {
                RemoteLogger.shared.logError(name: "Background task \(taskID) expired.",
                                          reason: "Sync time: \(Self.ElapsedTimeFormatter.string(from: startTime, to: Date()) ?? "unknown")")
                task.cancel()
                backgroundTask.setTaskCompleted(success: false)
            }

            task.start {
                backgroundTask.setTaskCompleted(success: true)
            }
        }

        if !isRegistered {
            RemoteLogger.shared.logError(name: "Failed to register background task \(taskID).")
        }
    }

    public func schedule(task: BGTaskRequest) {
        do {
            try scheduler.submit(task)
        } catch(let error) {
            RemoteLogger.shared.logError(name: "Failed to schedule background task \(task.identifier).", reason: error.localizedDescription)
        }
    }

    public func cancel(taskID: String) {
        scheduler.cancel(taskRequestWithIdentifier: taskID)
    }
}
