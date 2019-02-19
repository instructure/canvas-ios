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

    func testContextScope() {
        let one = Tab.make(["contextRaw": "course_1", "position": 0])
        let two = Tab.make(["contextRaw": "course_1", "position": 1])
        let three = Tab.make(["contextRaw": "course_1", "position": 2])
        let otherTab = Tab.make(["contextRaw": "group_1"])
        let list = environment.subscribe(Tab.self, .context(ContextModel(.course, id: "1")))
        list.performFetch()
        let objects = list.fetchedObjects

        XCTAssertEqual(objects, [one, two, three])
        XCTAssertEqual(objects?.contains(otherTab), false)
    }
}
