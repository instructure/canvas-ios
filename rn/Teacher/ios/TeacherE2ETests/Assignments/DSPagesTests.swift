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

import Foundation
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
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.pages.tap()
        XCTAssertTrue(PageList.emptyPageList().exists())
        XCTAssertFalse(PageList.page(index: 0).exists())

        // Let's add a page manually
        PageList.add.tap()
        let pageTitle = "This is a Page Title"
        PageEditor.titleField.pasteText(pageTitle)
        PageEditor.doneButton.tap()
        pullToRefresh()
        XCTAssertTrue(PageList.page(index: 0).exists())
        XCTAssertFalse(PageList.frontPageHeading.exists())

        // Let's create a page that is published and frontpage
        let seededPageTitle = "This is a seeded page"
        let seededPageContent = "This is the body of the seeded page"
        let seededPublishedFrontPage = seeder.createPage(courseId: course.id, requestBody: .init(title: seededPageTitle, body: seededPageContent, front_page: true, published: true))
        pullToRefresh()
        XCTAssertTrue(PageList.frontPageHeading.exists())
        PageList.frontPageHeading.tap()
        XCTAssertTrue(PageDetails.options.exists())
        pullToRefresh()
        XCTAssertTrue(app.find(id: "\(seededPublishedFrontPage.title), \(course.name)").exists())
        XCTAssertTrue(app.find(labelContaining: seededPublishedFrontPage.body).exists())
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
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.pages.tap()
        XCTAssertTrue(PageList.emptyPageList().exists())
        XCTAssertFalse(PageList.page(index: 0).exists())

        // Let's seed a published front page
        var seededPageTitle = "This is a Front page"
        let seededPageContent = "This is the body of the seeded page"
        _ = seeder.createPage(courseId: course.id, requestBody: .init(title: seededPageTitle, body: seededPageContent, front_page: true, published: true))
        pullToRefresh()
        XCTAssertTrue(PageList.frontPageHeading.exists())
        XCTAssertFalse(PageList.page(index: 0).exists())
        PageList.frontPageHeading.tap()
        PageDetails.options.tap()

        // Delete option should be missing if it is a front page
        XCTAssertFalse(app.find(label: "Delete").exists())
        XCTAssertTrue(app.find(label: "Edit").exists())
        app.find(label: "Edit").tap()
        seededPageTitle = "This is not a front page"
        PageEditor.titleField.pasteText(seededPageTitle)
        XCTAssertTrue(PageEditor.frontPageToggle.isEnabled)
        PageEditor.frontPageToggle.tap()
        XCTAssertTrue(PageEditor.publishedToggle.isEnabled)
        PageEditor.doneButton.tap()

        // Check for page to be updated with new title and no longer a front page and delete it
        pullToRefresh()
        XCTAssertFalse(PageList.frontPageHeading.exists())
        XCTAssertTrue(PageList.page(index: 0).exists())
        PageList.page(index: 0).tap()
        XCTAssertTrue(app.find(id: "\(seededPageTitle), \(course.name)").exists())
        PageDetails.options.tap()
        app.find(label: "Delete").tap()
        app.find(label: "OK").tap()
        pullToRefresh()
        XCTAssertTrue(PageList.emptyPageList().exists())
        XCTAssertFalse(PageList.frontPageHeading.exists())
        XCTAssertFalse(PageList.page(index: 0).exists())
    }
}
