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

/**
 This class stores the completion block received from the system when it wakes up the app via the application delegate because a background url session is completed.
 This entity also makes possible to lazy init the upload chain in `FileSubmissionAssembly` and setup the background callback after the assembly has been created
 and ensures that the callback block is executed on the main thread.
 */
public class BackgroundSessionCompletion {
    public var callback: (() -> Void)?

    public init() {}

    public func backgroundOperationsFinished() {
        guard let callback else {
            return
        }

        let semaphore = DispatchSemaphore(value: 0)
        performUIUpdate { [weak self] in
            callback()
            self?.callback = nil
            semaphore.signal()
        }
        semaphore.wait()
    }
}
