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

import Foundation

public enum LoginWeb: String, ElementWrapper {
    case webView

    public static var emailField: Element {
        return app.find(type: .textField)
        // return XCUIElementWrapper(app.webViews.textFields["Email"])
    }

    public static var passwordField: Element {
        return app.find(type: .secureTextField)
    }

    public static var logInButton: Element {
        return app.find(label: "Log In")
    }
}
