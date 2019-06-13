//
// Copyright (C) 2018-present Instructure, Inc.
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
import TestsFoundation

enum LoginStart: String, ElementWrapper {
    case authenticationMethodLabel
    case canvasNetworkButton
    case findSchoolButton
    case helpButton
    case logoView
    case whatsNewLabel
    case whatsNewLink
}

enum LoginStartKeychainEntry {
    static func cell(host: String, userID: String) -> Element {
        return app.find(id: "LoginStartKeychainEntry.\(host).\(userID)")
    }

    static func removeButton(host: String, userID: String) -> Element {
        return app.find(id: "LoginStartKeychainEntry.\(host).\(userID).removeButton")
    }
}

enum LoginStartMDMLogin {
    static func cell(host: String, username: String) -> Element {
        return app.find(id: "LoginStartMDMLogin.\(host).\(username)")
    }
}
