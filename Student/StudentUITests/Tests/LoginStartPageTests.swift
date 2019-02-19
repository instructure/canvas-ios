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

class LoginStartPageTests: StudentTest {
    let page = LoginStartPage.self

    func testHiddenElements() {
        show(Route.login.url.path)
        page.assertHidden(.helpButton)
        page.assertHidden(.whatsNewLabel)
        page.assertHidden(.whatsNewLink)
    }

    func testFindSchool() {
        show(Route.login.url.path)
        page.assertEnabled(.findSchoolButton)
        page.tap(.findSchoolButton)

        LoginFindSchoolPage.assertVisible(.searchField)
    }

    func testCanvasNetwork() {
        show(Route.login.url.path)
        page.assertEnabled(.canvasNetworkButton)
        page.tap(.canvasNetworkButton)

        LoginWebPage.assertVisible(.webView)
    }
}
