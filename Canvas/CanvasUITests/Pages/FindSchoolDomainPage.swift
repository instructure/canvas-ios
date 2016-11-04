
//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import XCTest
import SoAutomated

@available(iOS 9.0, *)
class FindSchoolDomainPage: TestPage {

    //# MARK: - Navigation Controller Element Locator Properties

    var findDomainTitle: XCUIElement {
        return app.staticTexts["Help"] // label
    }

    var doneButton: XCUIElement {
        return app.buttons["Done"] // label
    }

    //# MARK: - Webview H1 Tag Locator

    var webviewH1Tag: XCUIElement {
        return app.staticTexts["How do I find my institution's URL to access Canvas apps on my mobile device?"] // label
    }

    //# MARK: - Assertion Helpers

    func assertNavigationController(file: String = #file, _ line: UInt = #line) {
        assertExists(findDomainTitle, file, line)
        assertExists(doneButton, file, line)
    }

    func assertWebview(file: String = #file, _ line: UInt = #line) {
        assertExists(webviewH1Tag, file, line)
    }

    func assertPage(file: String = #file, _ line: UInt = #line) {
        assertNavigationController(file, line)
        assertWebview(file, line)
    }

    //# MARK: - UI Action Helpers

    func close() {
        tap(doneButton)
    }
}
