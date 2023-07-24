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

public enum LoginWeb: String, ElementWrapper {
    case webView

    public static var emailField: Element {
        return app.find(id: "LoginWeb.webView").rawElement.find(type: .textField)
    }

    public static var passwordField: Element {
        return app.find(id: "LoginWeb.webView").rawElement.find(type: .secureTextField)
    }

    public static var logInButton: Element {
        return app.find(id: "LoginWeb.webView").rawElement.find(type: .button)
    }

    public static var createAccountLabel: Element {
        app.webViews.staticTexts.matching(label: "Create Account").firstElement
    }

    public static var studentPairingCodeLabel: Element {
        app.webViews.staticTexts.matching(label: "Student Pairing Code").firstElement
    }

    public static var parentCreateAccountButton: Element {
        app.webViews.buttons.matching(label: "Start Participating").firstElement
    }
}
