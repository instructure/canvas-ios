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
import XCTest
@testable import Core

class TabTests: CoreTestCase {
    func testProperties() {
        let tab = Tab.make()

        tab.context = ContextModel(.group, id: "5")
        XCTAssertEqual(tab.context as? ContextModel, ContextModel(.group, id: "5"))
        tab.contextRaw = "bogus"
        XCTAssertEqual(tab.context as? ContextModel, .currentUser)

        tab.hidden = nil
        XCTAssertNil(tab.hidden)
        tab.hidden = true
        XCTAssertEqual(tab.hidden, true)

        tab.type = .internal
        XCTAssertEqual(tab.type, .internal)
        tab.typeRaw = "bogus"
        XCTAssertEqual(tab.type, .external)

        tab.visibility = .public
        XCTAssertEqual(tab.visibility, .public)
        tab.visibilityRaw = "bogus"
        XCTAssertEqual(tab.visibility, .none)
    }
}
