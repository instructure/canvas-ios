//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

public class LoginHelper: BaseHelper {
    struct Start {
        public static var canvasLogo: Element { app.find(id: "instructureLine") }
        public static var canvasLabel: Element { app.find(id: "wordmark") }
        public static var lastLoginButton: Element { app.find(id: "LoginStart.lastLoginButton") }
        public static var findSchoolButton: Element { app.find(id: "LoginStart.findSchoolButton") }
        public static var qrCodeButton: Element { app.find(id: "LoginStart.qrCodeButton") }
        public static var canvasNetworkButton: Element { app.find(id: "LoginStart.canvasNetworkButton") }

        public static func previousLoginCell(dsUser: DSUser) -> Element {
            app.find(id: "LoginStartSession.\(user.host).\(dsUser.id)")
        }
        public static var invalidUsernameOrPasswordLabel: Element {
            app.find(labelContaining: "Invalid username or password", type: .staticText)
        }
    }

    struct FindSchool {
        public static var findSchoolLabel: Element { app.find(id: "instructureSolid") }
        public static var searchField: Element { app.find(id: "LoginFindSchool.searchField") }
        public static var howDoIFindMySchoolButton: Element { app.find(id: "LoginFindAccountResult.emptyCell") }
    }

    struct Login {
        static var webView: Element { app.find(id: "LoginWeb.webView") }
        static var linksOfWebview: [Element] { webView.waitToExist().rawElement.findAll(type: .link) }

        public static var navBar: Element { app.find(id: user.host) }
        public static var hostLabel: Element { navBar.rawElement.find(type: .staticText) }
        public static var emailField: Element { webView.rawElement.find(type: .textField) }
        public static var passwordField: Element { webView.rawElement.find(type: .secureTextField) }
        public static var loginButton: Element { webView.rawElement.find(type: .button) }
        public static var forgotPasswordButton: Element { linksOfWebview[1] }
        public static var needAccountButton: Element { linksOfWebview[0] }
        public static var noPasswordLabel: Element { app.find(labelContaining: "No password was given") }
    }
}
