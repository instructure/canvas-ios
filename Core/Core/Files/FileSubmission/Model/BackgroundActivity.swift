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

public class BackgroundActivity {
    public enum ActivityError: Error, Equatable {
        case failedToStartBackgroundActivity
    }

    private let processManager: ProcessManager
    private let abortHandler: () -> Void
    // This is to make the background block wait until we finish
    private var semaphore: DispatchSemaphore?
    private var isStarted: Bool { semaphore != nil }

    /**
     - parameters:
        - abortHandler: The block to be executed if the background activity is terminated by the OS.
                        All ongoing work must be stopped synchronously as fast as possible.
     */
    public init(processManager: ProcessManager, abortHandler: @escaping () -> Void) {
        self.processManager = processManager
        self.abortHandler = abortHandler
    }

    public func start() -> Future<Void, ActivityError> {
        if isStarted {
            return Future<Void, ActivityError> { $0(.success(())) }
        } else {
            return Future<Void, ActivityError> { self.requestBackgroundActivity($0) }
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
        semaphore = nil
    }

    private func requestBackgroundActivity(_ promise: @escaping Future<Void, ActivityError>.Promise) {
        processManager.performExpiringActivity(reason: "File Submission") { [self] expired in
            if expired {
                if isStarted {
                    abortHandler()
                    semaphore?.signal()
                    semaphore = nil
                } else {
                    promise(.failure(.failedToStartBackgroundActivity))
                }
            } else {
                semaphore = DispatchSemaphore(value: 0)
                promise(.success(()))
                semaphore?.wait()
            }
        }
    }
}
