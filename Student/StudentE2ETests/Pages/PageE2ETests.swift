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

class PageE2ETests: E2ETestCase {
    func testFrontPageLoadByDefault() {
        // MARK: Seed the usual stuff and a front page for the course
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let frontPage = DashboardHelper.createFrontPageForCourse(course: course)

        // MARK: Check course card
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        XCTAssertTrue(courseCard.isVisible)
        courseCard.tap()

        // MARK: Check pages button
        let pagesButton = CourseNavigation.pages.waitToExist()
        XCTAssertTrue(pagesButton.isVisible)
        pagesButton.tap()

        // MARK: Check front page button
        let frontPageButton = PageList.frontPage.waitToExist()
        XCTAssertTrue(frontPageButton.isVisible)
        frontPageButton.tap()

        // MARK: Check title of front page
        app.find(labelContaining: frontPage.title).waitToExist()
    }

    func testDeepLinks() {
        // MARK: Seed the usual stuff and a front page for the course
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let frontPage = DashboardHelper.createFrontPageForCourse(course: course)

        // MARK: Navigate to the front page of the course
        PagesHelper.navigateToFrontPage(course: course)

        // MARK: Check deep link to group-announcements
        app.find(labelContaining: "group-announcements").tap()
        app.find(labelContaining: "It looks like announcements haven’t been created in this space yet.").waitToExist()

        // MARK: Check deep link to group-home
        app.find(labelContaining: "group-home").tap()
        app.find(labelContaining: "Home").waitToExist()

        // MARK: Check deep link to public course
        app.find(labelContaining: "public-course-page").tap()
        app.find(labelContaining: "This is a public course").waitToExist()

        // MARK: Check deep link to discussion
        app.find(labelContaining: "discussion").tap()
        app.find(labelContaining: "A discussion").waitToExist()
    }
}
