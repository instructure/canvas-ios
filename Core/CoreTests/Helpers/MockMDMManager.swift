//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core

extension MDMManager {
    static func mockDefaults() {
        let defaults: [String: Any] = [
            "enableLogin": true,
            "users": [[
                "username": "apple",
                "password": "titaniumium",
                "host": "canvas.instructure.com"
            ] ]
        ]
        UserDefaults.standard.set(defaults, forKey: MDMManager.MDMUserDefaultsKey)
    }

    static func mockNoUsers() {
        let defaults: [String: Any] = [
            "enableLogin": true
        ]
        UserDefaults.standard.set(defaults, forKey: MDMManager.MDMUserDefaultsKey)
    }

    static func mockBadUsers() {
        let defaults: [String: Any] = [
            "enableLogin": true,
            "users": [
                [
                    "username": "apple",
                    "password": "titaniumium"
                ],
                [
                    "username": "apple",
                    "host": "canvas.instructure.com"
                ],
                [
                    "password": "titaniumium",
                    "host": "canvas.instructure.com"
                ]
            ]
        ]
        UserDefaults.standard.set(defaults, forKey: MDMManager.MDMUserDefaultsKey)
    }

    static func mockHost() {
        let defaults: [String: Any] = [
            "enableLogin": true,
            "host": "canvas.instructure.com",
            "authenticationProvider": "canvas"
        ]
        UserDefaults.standard.set(defaults, forKey: MDMManager.MDMUserDefaultsKey)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: MDMManager.MDMUserDefaultsKey)
    }
}
