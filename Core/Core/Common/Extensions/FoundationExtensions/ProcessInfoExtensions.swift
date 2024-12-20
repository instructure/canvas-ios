//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol ProcessManager {
    /**
     Perform an expiring background task, which obtains an expiring task assertion on iOS. The block contains any work which needs to be completed as a background-priority task. The block will be scheduled on a system-provided concurrent queue. After a system-specified time, the block will be called with the `expired` parameter set to YES. The `expired` parameter will also be YES if the system decides to prematurely terminate a previous non-expiration invocation of the block.
     */
    func performExpiringActivity(reason: String, completion: @escaping (Bool) -> Void)

}

extension ProcessInfo: ProcessManager {
    public func performExpiringActivity(reason: String, completion: @escaping (Bool) -> Void) {
        performExpiringActivity(withReason: reason, using: completion)
    }
}

extension ProcessInfo {
    public static var isUITest: Bool {
        return processInfo.environment["IS_UI_TEST"] != nil
    }
}

public var unitTesting: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

public var uiTesting: Bool {
    return ProcessInfo.isUITest
}

public var testing: Bool {
    return unitTesting || uiTesting
}
