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

import Foundation

public enum BackgroundProcessingAssembly {

    public static func resolveInteractor() -> BackgroundProcessingInteractor {
        BackgroundProcessingInteractor(scheduler: scheduler)
    }

    // MARK: - Injecting BGTaskScheduler Implementation

    private static var scheduler: CoreBGTaskScheduler!

    public static func register(scheduler: CoreBGTaskScheduler) {
        self.scheduler = scheduler
    }

    // MARK: - Task Management

    private static var factoriesByID: [String: () -> BackgroundTask] = [:]

    public static func register(taskID: String,
                                using taskFactory: @escaping () -> BackgroundTask) {
        factoriesByID[taskID] = taskFactory
    }

    public static func resetRegisteredTaskIDs() {
        factoriesByID.removeAll()
    }

    public static func resolveTask(for ID: String) -> BackgroundTask? {
        factoriesByID[ID]?()
    }
}
