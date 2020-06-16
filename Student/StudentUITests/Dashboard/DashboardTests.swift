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
import CoreUITests
@testable import Core

class DashboardTests: StudentUITestCase {
    func course(_ id: ID, is_favorite: Bool? = nil) -> APICourse {
        APICourse.make(id: id, name: "Course \(id)", course_code: "C\(id)", is_favorite: is_favorite)
    }

    func card(_ id: ID) -> APIDashboardCard {
        return APIDashboardCard.make(
            assetString: "course_\(id)",
            courseCode: "C\(id)",
            href: "/courses/\(id)",
            id: id,
            longName: "Course \(id)",
            originalName: "Course \(id)",
            shortName: "Course \(id)"
        )
    }

    func checkCoursesEditMenu(_ courses: [APICourse]) {
        for course in courses {
            XCTAssertEqual(DashboardEdit.courseFavorite(id: course.id.value, favorited: course.is_favorite ?? false).label(), course.name)
        }
    }

    func checkDashboard(_ courses: [APICourse]) {
        let noFavorites = courses.allSatisfy { $0.is_favorite != true }
        for course in courses {
            if course.is_favorite == true || noFavorites {
                XCTAssertEqual(Dashboard.courseCard(id: course.id.value).label(), course.name)
            } else {
                Dashboard.courseCard(id: course.id.value).waitToVanish()
            }
        }
    }

    func xtestEditFavorites() {
        mockBaseRequests()

        mockData(GetDashboardCardsRequest(), value: [card(2)])
        // start with course 2 favorited
        var courses = mock(courses: [course(1), course(2, is_favorite: true), course(3)])
        for course in courses {
            mockData(PostFavoriteRequest(context: .course(course.id.value)), value: APIFavorite(context_id: course.id, context_type: "course"))
        }

        // TODO: figure out what's really going on with the never-appearing dashboard
        sleep(1)
        logIn()

        // favorite 3
        checkDashboard(courses)
        Dashboard.editButton.tap()
        checkCoursesEditMenu(courses)
        mockData(GetDashboardCardsRequest(), value: [card(2), card(3)])
        courses = mock(courses: [course(1), course(2, is_favorite: true), course(3, is_favorite: true)])
        DashboardEdit.courseFavorite(id: "3", favorited: false).tap()
        checkCoursesEditMenu(courses)

        NavBar.dismissButton.tap()
        checkDashboard(courses)

        // unfavorite all
        Dashboard.editButton.tap()
        mockData(GetDashboardCardsRequest(), value: [card(1), card(2), card(3)])
        courses = mock(courses: [course(1), course(2), course(3)])
        DashboardEdit.courseFavorite(id: "3", favorited: true).tap()
        DashboardEdit.courseFavorite(id: "2", favorited: true).tap()
        checkCoursesEditMenu(courses)

        NavBar.dismissButton.tap()
        checkDashboard(courses)

        // favorite 1
        Dashboard.editButton.tap()
        checkCoursesEditMenu(courses)
        mockData(GetDashboardCardsRequest(), value: [card(1)])
        courses = mock(courses: [course(1, is_favorite: true), course(2), course(3)])
        DashboardEdit.courseFavorite(id: "1", favorited: false).tap()
        checkCoursesEditMenu(courses)

        NavBar.dismissButton.tap()
        checkDashboard(courses)

        Dashboard.seeAllButton.tap()
        checkDashboard([course(1), course(2), course(3)])
    }
}
