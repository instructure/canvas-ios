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
import XCTest
@testable import Core

class TabTests: CoreTestCase {
    func testProperties() {
        let tab = Tab.make()

        tab.context = Context(.group, id: "5")
        XCTAssertEqual(tab.context, Context(.group, id: "5"))
        tab.contextRaw = "bogus"
        XCTAssertEqual(tab.context, .currentUser)

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

    func testSavesIsHiddenProperty() {
        let context = Context(.group, id: "1")
        let tab = Tab.make()

        tab.save(.make(hidden: nil), in: databaseClient, context: context)
        XCTAssertNil(tab.hidden)

        tab.save(.make(hidden: false), in: databaseClient, context: context)
        XCTAssertEqual(tab.hidden, false)

        tab.save(.make(hidden: true), in: databaseClient, context: context)
        XCTAssertEqual(tab.hidden, true)
    }
}
