//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

extension MDMManager {
    static func mockAppleDefaults() {
        let key = MDMProvider.apple.rawValue
        let defaults: [String: Any] = [
            "enableDemo": true,
            "username": "apple",
            "password": "titaniumium",
        ]
        UserDefaults.standard.set(defaults, forKey: key)
    }

    static func mockDefaults() {
        let key = MDMProvider.instructure.rawValue
        let defaults: [String: Any] = [
            "enableLogin": true,
            "host": "canvas.instructure.com",
            "username": "canvas",
            "password": "password",
        ]
        UserDefaults.standard.set(defaults, forKey: key)
    }

    static func reset() {
        MDMProvider.allCases.forEach {
            UserDefaults.standard.set(nil, forKey: $0.rawValue)
        }
    }
}
