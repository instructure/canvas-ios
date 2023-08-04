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

public class LoginHelper: BaseHelper {
    public struct Start {
        public static var canvasLogo: XCUIElement { app.find(id: "instructureLine") }
        public static var canvasLabel: XCUIElement { app.find(id: "wordmark") }
        public static var lastLoginButton: XCUIElement { app.find(id: "LoginStart.lastLoginButton") }
        public static var findSchoolButton: XCUIElement { app.find(id: "LoginStart.findSchoolButton") }
        public static var qrCodeButton: XCUIElement { app.find(id: "LoginStart.qrCodeButton") }
        public static var canvasNetworkButton: XCUIElement { app.find(id: "LoginStart.canvasNetworkButton") }
        public static var dontHaveAccountAction: XCUIElement { app.find(id: "LoginStart.dontHaveAccountAction") }

        public static func previousLoginCell(dsUser: DSUser) -> XCUIElement {
            app.find(id: "LoginStartSession.\(user.host).\(dsUser.id)")
        }
        public static var invalidUsernameOrPasswordLabel: XCUIElement {
            app.find(labelContaining: "Invalid username or password", type: .staticText)
        }
    }

    public struct FindSchool {
        public static var findSchoolLabel: XCUIElement { app.find(id: "instructureSolid") }
        public static var searchField: XCUIElement { app.find(id: "LoginFindSchool.searchField") }
        public static var howDoIFindMySchoolButton: XCUIElement { app.find(id: "LoginFindAccountResult.emptyCell") }
        public static var keyboardGoButton: XCUIElement { app.find(type: .keyboard).find(id: "Go") }
        public static var nextButton: XCUIElement { app.find(id: "nextButton", type: .button) }
    }

    public struct Login {
        public static var webView: XCUIElement { app.find(id: "LoginWeb.webView").waitUntil(.visible) }
        public static var linksOfWebView: [XCUIElement] { webView.findAll(type: .link, minimumCount: 2) }

        public static var navBar: XCUIElement { app.find(id: user.host) }
        public static var hostLabel: XCUIElement { navBar.find(type: .staticText) }
        public static var emailField: XCUIElement { webView.find(type: .textField) }
        public static var passwordField: XCUIElement { webView.find(type: .secureTextField) }
        public static var loginButton: XCUIElement { webView.find(type: .button) }
        public static var forgotPasswordButton: XCUIElement { linksOfWebView[1] }
        public static var needAccountButton: XCUIElement { linksOfWebView[0] }
        public static var noPasswordLabel: XCUIElement { app.find(labelContaining: "No password was given") }

        public static var studentPairingCodeLabel: XCUIElement { webView.find(label: "Student Pairing Code") }
        public static var parentCreateAccountButton: XCUIElement { webView.find(label: "Start Participating") }
    }

    public struct LoginStartSession {
        public static func cell(host: String, userID: String) -> XCUIElement {
            return app.find(id: "LoginStartSession.\(host).\(userID)")
        }
    }

    public struct PairWithStudentQR {
        public static var nextButton: XCUIElement { app.find(id: "PairWithStudentQRCodeTutorial.nextButton") }
        public static var headerLabel: XCUIElement { app.find(id: "PairWithStudentQRCodeTutorial.headerLabel") }
    }
}
