//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

enum CoursePeople {
    static func person(name: String) -> Element {
        return app.find(label: name)
    }
}

enum PersonContextCard {
    static func text(_ text: String) -> Element {
        return app.staticTexts.matching(label: text).firstElement
    }
}

class PeopleE2ETests: CoreUITestCase {
    func testCourseUsersAndUserContextCardDisplay() {
        // Dashboard
        Dashboard.courseCard(id: "262").tapUntil {
            CourseNavigation.people.exists()
        }

        CourseNavigation.people.tapUntil {
            CoursePeople.person(name: "Student One").exists()
        }

        XCTAssertTrue(CoursePeople.person(name: "Student Two").exists())
        CoursePeople.person(name: "Student One").tapUntil {
            PersonContextCard.text("Student One").exists()
        }

        XCTAssertTrue(PersonContextCard.text("Announcments").exists())
    }
}
