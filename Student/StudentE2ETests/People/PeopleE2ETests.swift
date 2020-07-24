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
    static func emailLabel(_ email: String) -> Element {
        return app.staticTexts.matching(label: email).firstElement
    }
}

class PeopleE2ETests: CoreUITestCase {
    func testCourseUsersAndUserContextCardDisplay() {
        // Dashboard
        Dashboard.courseCard(id: "262").tap()

        CourseNavigation.people.tap()

        CoursePeople.person(name: "Student One").waitToExist()
        CoursePeople.person(name: "Student Two").waitToExist()
        CoursePeople.person(name: "Student One").tap()

        PersonContextCard.emailLabel("ios+student1@instructure.com").waitToExist()
    }
}
