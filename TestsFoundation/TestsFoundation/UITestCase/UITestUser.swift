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

public class UITestUser {
    public static let readStudent1 = UITestUser(.testReadStudent1)
    public static let readStudent2 = UITestUser(.testReadStudent2)
    public static let readTeacher1 = UITestUser(.testReadTeacher1)
    public static let ldapUser = UITestUser(.testLDAPUser)

    public let host: String
    public let username: String
    public let password: String
    public var keychainEntry: KeychainEntry?

    public var profile: String {
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
        .replacingOccurrences(of: "[\\n\\s]", with: "", options: .regularExpression, range: nil)
    }

    private init(_ secret: Secret) {
        // crash tests if secret is invalid or missing
        let url = URLComponents.parse(secret.string!)
        host = url.host!
        username = url.user!
        password = url.password!
    }
}
