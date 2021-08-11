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
        K5CourseCard.courseCard(id: "21025").tap()
        CourseNavigation.discussions.waitToExist()
        CourseNavigation.grades.waitToExist()
        CourseNavigation.people.waitToExist()
        CourseNavigation.syllabus.waitToExist()
        XCTAssertEqual(CourseNavigation.syllabus.label(), "Important Info")

        CourseNavigation.discussions.tap()
        app.find(labelContaining: "K5 disco").waitToExist()
        NavBar.backButton.tap()

        CourseNavigation.people.tap()
        CoursePeople.person(name: "iOS Student K5").waitToExist()

        NavBar.backButton.tap()
        NavBar.backButton.tap()
        K5NavigationBar.homeroom.waitToExist()
        app.find(labelContaining: "My Subjects").waitToExist()
    }

    func testK5Reset() {
        XCTAssertFalse(K5CourseCard.courseCard(id: "21025").exists(), "K5 course seems to be visible before app reset")
        setUpK5()
        K5CourseCard.courseCard(id: "21025").waitToExist()
    }

    func setUpK5() {
        K5NavigationBar.homeroom.waitToExist()
        super.resetAppStateForK5()
        pullToRefresh()
        K5NavigationBar.homeroom.waitToExist()
    }
}
