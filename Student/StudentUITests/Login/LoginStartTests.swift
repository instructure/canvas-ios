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
@testable import Core
import TestsFoundation
import XCTest

class LoginStartTests: StudentUITestCase {
    func testHiddenElements() {
        show(Route.login.url.path)
        XCTAssertFalse(LoginStart.helpButton.isVisible)
        XCTAssertFalse(LoginStart.whatsNewLabel.isVisible)
        XCTAssertFalse(LoginStart.whatsNewLink.isVisible)
    }

    func testFindSchool() {
        show(Route.login.url.path)
        XCTAssertTrue(LoginStart.findSchoolButton.isEnabled)
        LoginStart.findSchoolButton.tap()

        LoginFindSchool.searchField.waitToExist()
    }

    func testCanvasNetwork() {
        show(Route.login.url.path)
        XCTAssertTrue(LoginStart.canvasNetworkButton.isEnabled)
        LoginStart.canvasNetworkButton.tap()

        LoginWeb.webView.waitToExist()
    }
}
