//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import TestsFoundation

class DSPagesTests: E2ETestCase {
    func testCreatePages() {
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let student = users[0]
        let teacher = users[1]

        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        // Check for empty PageList
        logInDSUser(teacher)
        pullToRefresh()
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .pages).hit()
        pullToRefresh()
        XCTAssertTrue(PagesHelper.emptyPage.waitUntil(condition: .visible).isVisible)
        XCTAssertFalse(PagesHelper.page(index: 0).waitUntil(condition: .vanish).isVisible)

        // Let's add a page manually
        PagesHelper.add.hit()
        let pageTitle = "This is a Page Title"
        PagesHelper.Editor.title.writeText(text: pageTitle)
        PagesHelper.Editor.done.hit()
        pullToRefresh()
        XCTAssertTrue(PagesHelper.page(index: 0).waitUntil(condition: .visible).isVisible)
        XCTAssertFalse(PagesHelper.frontPageHeading.waitUntil(condition: .visible).isVisible)

        // Let's create a page that is published and frontpage
        let seededPageTitle = "This is a seeded page"
        let seededPageContent = "This is the body of the seeded page"
        let seededPublishedFrontPage = seeder.createPage(courseId: course.id, requestBody: .init(title: seededPageTitle, body: seededPageContent, front_page: true, published: true))
        pullToRefresh()
        XCTAssertTrue(PagesHelper.frontPageHeading.waitUntil(condition: .visible).isVisible)

        PagesHelper.frontPageHeading.hit()
        XCTAssertTrue(PagesHelper.Details.options.waitUntil(condition: .visible).isVisible)

        pullToRefresh()
        XCTAssertTrue(app.find(id: "\(seededPublishedFrontPage.title), \(course.name)").waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: seededPublishedFrontPage.body).waitUntil(condition: .visible).isVisible)
    }

    // Enable this once https://instructure.atlassian.net/browse/MBL-15906 is fixed
    func testDeletePage() {
        let users = seeder.createUsers(2)
        let course = seeder.createCourse()
        let student = users[0]
        let teacher = users[1]

        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        // Check for empty PageList
        logInDSUser(teacher)
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .pages).hit()
        XCTAssertTrue(PagesHelper.emptyPage.waitUntil(condition: .visible).isVisible)
        XCTAssertFalse(PagesHelper.page(index: 0).waitUntil(condition: .vanish).isVisible)

        // Let's seed a published front page
        var seededPageTitle = "This is a Front page"
        let seededPageContent = "This is the body of the seeded page"
        seeder.createPage(courseId: course.id, requestBody: .init(title: seededPageTitle, body: seededPageContent, front_page: true, published: true))
        pullToRefresh()
        XCTAssertTrue(PagesHelper.frontPageHeading.waitUntil(condition: .visible).isVisible)
        XCTAssertFalse(PagesHelper.page(index: 0).waitUntil(condition: .vanish).isVisible)
        PagesHelper.frontPageHeading.hit()
        PagesHelper.Details.options.hit()

        // Delete option should be missing if it is a front page
        XCTAssertFalse(app.find(label: "Delete").waitUntil(condition: .vanish).isVisible)
        XCTAssertTrue(app.find(label: "Edit").waitUntil(condition: .visible).isVisible)
        app.find(label: "Edit").hit()
        seededPageTitle = "This is not a front page"
        PagesHelper.Editor.title.writeText(text: seededPageTitle)
        XCTAssertTrue(PagesHelper.Editor.frontPage.waitUntil(condition: .enabled).isEnabled)
        PagesHelper.Editor.frontPage.hit()
        XCTAssertTrue(PagesHelper.Editor.published.waitUntil(condition: .enabled).isEnabled)
        PagesHelper.Editor.done.hit()

        // Check for page to be updated with new title and no longer a front page and delete it
        pullToRefresh()
        XCTAssertFalse(PagesHelper.frontPageHeading.waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(PagesHelper.page(index: 0).waitUntil(condition: .visible).isVisible)
        PagesHelper.page(index: 0).hit()
        XCTAssertTrue(app.find(id: "\(seededPageTitle), \(course.name)").waitUntil(condition: .visible).isVisible)
        PagesHelper.Details.options.hit()
        app.find(label: "Delete").hit()
        app.find(label: "OK").hit()
        pullToRefresh()
        XCTAssertTrue(PagesHelper.emptyPage.waitUntil(condition: .visible).isVisible)
        XCTAssertFalse(PagesHelper.frontPageHeading.waitUntil(condition: .vanish).isVisible)
        XCTAssertFalse(PagesHelper.page(index: 0).waitUntil(condition: .vanish).isVisible)
    }
}
