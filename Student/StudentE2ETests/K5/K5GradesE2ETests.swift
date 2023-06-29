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

class K5GradesE2ETests: K5UITestCase {
    func testK5GradesE2E() {
        setUpK5()

        K5CourseCard.courseCard(id: "21025").waitToExist()
        K5NavigationBar.grades.tap()
        K5Grades.gradingPeriodSelectorClosed.waitToExist()
        K5Grades.gradingPeriodSelectorClosed.tap()
        K5Grades.gradingPeriodSelectorOpen.waitToExist()
        app.find(labelContaining: "MATH").waitToExist()
        app.find(labelContaining: "MATH").tap()
        K5CourseGrades.emptyGradesForCourse.waitToExist()
        NavBar.backButton.tap()
        app.find(labelContaining: "AUTOMATION 101").waitToExist()
        app.find(labelContaining: "AUTOMATION 101").tap()
        app.find(label: "Auto Intro").waitToExist()
        K5CourseGrades.gradedPointsMax(maxPoints: "5").waitToExist()
        K5CourseGrades.gradedPointsActual(actualPoints: "4").waitToExist()
    }
}
