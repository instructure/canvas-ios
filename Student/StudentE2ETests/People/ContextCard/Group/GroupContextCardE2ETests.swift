//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import XCTest
import TestsFoundation

enum ContextCard: String, ElementWrapper {
    case userNameLabel, groupLabel
}

class GroupContextCardE2ETests: CoreUITestCase {

    func testContextCardDisplays() {
        app.swipeUp()
        Dashboard.groupCard(id: "35").tap()
        app.find(labelContaining: "People").tap()

        CoursePeople.person(name: "Student One").waitToExist()
        CoursePeople.person(name: "Student Two").waitToExist()

        CoursePeople.person(name: "Student Two").tap()
        XCTAssertEqual(ContextCard.userNameLabel.label(), "Student Two")
        XCTAssertEqual(ContextCard.groupLabel.label(), "Group One")
    }
}
