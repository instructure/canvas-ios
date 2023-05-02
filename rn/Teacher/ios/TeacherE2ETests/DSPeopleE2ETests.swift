//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import TestsFoundation

class DSPeopleE2ETests: E2ETestCase {
    // Follow-up of MBL-15555
    func testPeopleListRoleE2E() {
        let studentIndex = 1
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let teacher = users[0]
        let student = users[studentIndex]
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        logInDSUser(teacher)
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.people.tap()

        PeopleListCell.cell(index: studentIndex).waitToExist()

        XCTAssertEqual(PeopleListCell.name(index: studentIndex), student.name)
        XCTAssertEqual(PeopleListCell.role(index: studentIndex), "Student")
        PeopleListCell.cell(index: studentIndex).tap()
        NavBar.backButton.tap()
        PeopleListCell.cell(index: studentIndex).waitToExist()
        XCTAssertEqual(PeopleListCell.role(index: studentIndex), "Student")
    }
}
