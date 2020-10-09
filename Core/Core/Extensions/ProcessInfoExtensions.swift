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
    func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void)
}

extension ProcessInfo: ProcessManager {}
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
