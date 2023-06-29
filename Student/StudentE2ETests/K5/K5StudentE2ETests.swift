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
@testable import Core

class K5StudentE2ETests: K5UITestCase {

    func testStudentK5() {
        setUpK5()

        K5CourseCard.courseCard(id: "21025").waitToExist()
        K5Dashboard.accountNotificationString.waitToExist()
        K5CourseCard.courseCard(id: "21025").tap()

        K5CourseNavigation.homeTab.waitToExist()
        K5CourseNavigation.scheduleTab.waitToExist()
        K5CourseNavigation.gradesTab.waitToExist()
        K5CourseNavigation.modulesTab.waitToExist()

        K5CourseNavigation.gradesTab.tap()
        K5CourseGrades.emptyGradesForCourse.waitToExist()

        K5CourseNavigation.modulesTab.tap()
        K5CourseModulesPage.emptyPage.waitToExist()

    }
}
