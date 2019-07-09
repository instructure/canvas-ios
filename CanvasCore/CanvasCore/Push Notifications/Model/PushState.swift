//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

public enum PushPreAuthStatus: Int {
    case neverShown = 0
    case shownAndAccepted
    case shownAndDeclined
    
    fileprivate static let pushPreAuthStatusKey = "com.instructure.canvas.pushPreAuthStatusKey"
    
    public static func currentPushPreAuthStatus() -> PushPreAuthStatus {
        let defaults = UserDefaults.standard
        if let status = PushPreAuthStatus(rawValue: defaults.integer(forKey: pushPreAuthStatusKey)) {
            return status
        } else {
            PushPreAuthStatus.registerDefaults()
            return PushPreAuthStatus.currentPushPreAuthStatus()
        }
    }
    
    public static func setCurrentPushPreAuthStatus(_ status: PushPreAuthStatus) {
        let defaults = UserDefaults.standard
        defaults.set(status.rawValue, forKey: pushPreAuthStatusKey)
        defaults.synchronize()
    }
    
    fileprivate static func registerDefaults() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [pushPreAuthStatusKey: PushPreAuthStatus.neverShown.rawValue])
        defaults.synchronize()
    }
}
