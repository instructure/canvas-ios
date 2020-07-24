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

import Foundation
import TestsFoundation
@testable import Core

class DashboardTests: MiniCanvasUITestCase {
    func editMenu(course: MiniCourse) -> Element {
        DashboardEdit.courseFavorite(id: course.id, favorited: course.api.is_favorite ?? false)
    }

    func checkCoursesEditMenu() {
        for course in mocked.courses {
            print(editMenu(course: course).queryWrapper.query)
            XCTAssertEqual(editMenu(course: course).label(), course.api.name)
        }
    }

    func checkDashboard(seeAll: Bool = false) {
        let noFavorites = mocked.courses.allSatisfy({ $0.api.is_favorite != true })
        for course in mocked.courses {
            if course.api.is_favorite == true || seeAll || noFavorites {
                XCTAssertEqual(Dashboard.courseCard(id: course.id).label(), course.api.name)
            } else {
                Dashboard.courseCard(id: course.id).waitToVanish()
            }
        }
    }

    func toggleFavorite(_ course: MiniCourse) {
        let originalState = course.api.is_favorite
        editMenu(course: course).tap()
        waitUntil { course.api.is_favorite != originalState }
    }

    func xtestEditFavorites() {
        // start with course 1 favorited
        mocked.courses[1].api.is_favorite = true

        pullToRefresh()

        // favorite 2
        checkDashboard()
        Dashboard.editButton.tap()
        checkCoursesEditMenu()
        toggleFavorite(mocked.courses[2])
        checkCoursesEditMenu()

        NavBar.dismissButton.tap()
        checkDashboard()

        // unfavorite all
        Dashboard.editButton.tap()
        toggleFavorite(mocked.courses[1])
        toggleFavorite(mocked.courses[2])
        checkCoursesEditMenu()

        NavBar.dismissButton.tap()
        checkDashboard()

        // favorite 0
        Dashboard.editButton.tap()
        checkCoursesEditMenu()
        toggleFavorite(mocked.courses[0])
        checkCoursesEditMenu()

        NavBar.dismissButton.tap()
        checkDashboard()

        Dashboard.seeAllButton.tap()
        checkDashboard(seeAll: true)
    }
}
