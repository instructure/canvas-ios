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
import Core

public enum LoginStart: String, ElementWrapper {
    case authenticationMethodLabel
    case canvasNetworkButton
    case findSchoolButton
    case lastLoginButton
    case logoView
    case whatsNewLabel
    case whatsNewLink
    case qrCodeButton
    case dontHaveAccountAction
}

public enum LoginStartSession {
    public static func cell(host: String, userID: String) -> Element {
        return app.find(id: "LoginStartSession.\(host).\(userID)")
    }

    public static func cell(_ entry: LoginSession) -> Element {
        return cell(host: entry.baseURL.host!, userID: entry.userID)
    }

    public static func removeButton(host: String, userID: String) -> Element {
        return app.find(id: "LoginStartKeychainEntry.\(host).\(userID).removeButton")
    }
}

public enum LoginStartMDMLogin {
    public static func cell(host: String, username: String) -> Element {
        return app.find(id: "LoginStartMDMLogin.\(host).\(username)")
    }
}

public enum PairWithStudentQRCodeTutorial: String, ElementWrapper {
    case nextButton
    case headerLabel
}
