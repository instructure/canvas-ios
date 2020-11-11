//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import WidgetKit

class CommonWidgetController {
    let env = AppEnvironment.shared
    var isLoggedIn: Bool { LoginSession.mostRecent != nil }
    lazy var colors = env.subscribe(GetCustomColors())
    var isDeviceUnlocked: Bool {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return false
        }
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent("lock-screen-text.txt")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                _ = try Data(contentsOf: fileURL)
                return true
            } catch {
                return false // read failed, must be locked
            }
        }

        do {
            guard let data = "Lock screen test".data(using: .utf8) else { return true }
            try data.write(to: fileURL, options: .completeFileProtection)
            return true
        } catch {
            return false // default to locked to be safe
        }
    }

    func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session)
    }
}
