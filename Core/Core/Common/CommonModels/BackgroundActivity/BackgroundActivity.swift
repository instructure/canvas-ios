//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import Foundation

public class BackgroundActivity {
    private let processManager: ProcessManager
    private let activityName: String
    // This is to make the background block wait until we finish
    private var semaphore: DispatchSemaphore?
    private var abortHandler: (() -> Void)?
    private var isStarted: Bool { semaphore != nil }

    /**
     - parameters:
        - abortHandler: The block to be executed if the background activity is terminated by the OS.
                        All ongoing work must be stopped synchronously as fast as possible.
     */
    public init(processManager: ProcessManager,
                activityName: String) {
        self.processManager = processManager
        self.activityName = activityName
    }

    deinit {
        // If the instance was released and stop wasn't called, we call it to prevent
        // the leaking background activity from crashing the app.
        if semaphore != nil {
            stopAndWait()
        }
    }

    public func start(abortHandler: @escaping () -> Void) -> Future<Void, Never> {
        self.abortHandler = abortHandler
        return Future<Void, Never> { [self] promise in
            if isStarted {
                promise(.success(()))
            } else {
                requestBackgroundActivity(promise)
            }
        }
    }

    public func stop() -> Future<Void, Never> {
        Future<Void, Never> {
            self.stopAndWait()
            $0(.success(()))
        }
    }

    /**
     Stops the background activity synchronously.
     */
    public func stopAndWait() {
        semaphore?.signal()
        abortHandler = nil
    }

    private func requestBackgroundActivity(_ promise: @escaping Future<Void, Never>.Promise) {
        processManager.performExpiringActivity(reason: activityName) { [self] expired in
            if expired {
                if isStarted {
                    Logger.shared.error("performExpiringActivity was aborted by the OS")
                    RemoteLogger.shared.logError(name: "performExpiringActivity was aborted by the OS")
                    abortHandler?()
                    semaphore?.signal()
                } else {
                    Logger.shared.error("performExpiringActivity failed to start")
                    RemoteLogger.shared.logError(name: "performExpiringActivity failed to start")
                    promise(.success(()))
                }
                abortHandler = nil
            } else {
                semaphore = DispatchSemaphore(value: 0)
                promise(.success(()))
                semaphore?.wait()
                semaphore = nil
                abortHandler = nil
            }
        }
    }
}
