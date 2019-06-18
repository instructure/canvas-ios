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

import Core
import XCTest
import TestsFoundation

enum User: String {
    case student1

    var username: String {
        return rawValue
    }

    var password: String {
        return "password"
    }

    var host: String {
        return "iosauto.instructure.com"
    }

    var profile: String {
        return """
            <dict>
                <key>enableLogin</key><true/>
                <key>users</key>
                <array>
                    <dict>
                        <key>host</key><string>\(host)</string>
                        <key>username</key><string>\(username)</string>
                        <key>password</key><string>\(password)</string>
                    </dict>
                </array>
            </dict>
        """
        .replacingOccurrences(of: "[\\n,\\s]", with: "", options: .regularExpression, range: nil)
    }
}

class CanvasUITests: UITestCase {
    var user: User? { return nil }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if app.state != .runningForeground {
            launch()
        }
        reset()
        if let user = user {
            LoginStart.previousUser(name: user.username).tap()
        }
    }

    func launch() {
        let app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            "-com.apple.configuration.managed",
            User.student1.profile
        ])
        app.launchEnvironment["IS_UI_TEST"] = "TRUE"
        app.launch()
        // Wait for RN to finish loading
        app.find(labelContaining: "Loading").waitToVanish(120)
    }
}
