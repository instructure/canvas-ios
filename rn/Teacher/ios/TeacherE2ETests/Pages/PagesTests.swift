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

import TestsFoundation

class PagesTests: E2ETestCase {
    func testFrontPageLoadsByDefault() {
        // MARK: Seed the usual stuff and a front page for the course
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let frontPage = DashboardHelper.createFrontPageForCourse(course: course)

        // MARK: Get the user logged in and check the course card
        logInDSUser(teacher)

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        courseCard.hit()

        // MARK: Check pages button
        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertTrue(pagesButton.isVisible)
        pagesButton.hit()

        // MARK: Check front page button
        let frontPageButton = PagesHelper.frontPage.waitUntil(.visible)
        XCTAssertTrue(frontPageButton.isVisible)
        frontPageButton.hit()

        // MARK: Check title of front page
        let frontPageTitle = PagesHelper.titleByText(text: frontPage.title).waitUntil(.visible)
        XCTAssertTrue(frontPageTitle.isVisible)
    }

    func testDeepLinks() {
        // MARK: Seed the usual stuff and a front page containing some deep links
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let assignmentName = "Deep Link Assignment"
        let assignment = AssignmentsHelper.createAssignment(course: course, name: assignmentName)
        let assignmentLink = PagesHelper.createLinkToAssignment(course: course, assignment: assignment)

        let discussionTitle = "Deep Link Discussion"
        let discussion = DiscussionsHelper.createDiscussion(course: course, title: discussionTitle)
        let discussionLink = PagesHelper.createLinkToDiscussion(course: course, discussion: discussion)

        let announcementTitle = "Deep Link Announcement"
        let announcement = DiscussionsHelper.createDiscussion(course: course, title: announcementTitle, isAnnouncement: true)
        let announcementLink = PagesHelper.createLinkToDiscussion(course: course, discussion: announcement)

        let body = "\(assignmentLink)\n\(discussionLink)\n\(announcementLink)"
        PagesHelper.createDeepLinkFrontPage(course: course, body: body)

        // MARK: Enroll user in course, get user logged in
        seeder.enrollTeacher(teacher, in: course)

        logInDSUser(teacher)

        // MARK: Navigate to front page of course
        PagesHelper.navigateToFrontPage(course: course)

        // MARK: Check deep link to assignment
        let assignmentDeepLink = app.find(labelContaining: assignment.name).waitUntil(.visible)
        XCTAssertTrue(assignmentDeepLink.isVisible)
        assignmentDeepLink.hit()
        let assignmentDetailsNavBar = AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(assignmentDetailsNavBar.isVisible)

        AssignmentsHelper.Details.backButton.hit()

        // MARK: Check deep link to discussion
        let discussionDeepLink = app.find(labelContaining: discussion.title).waitUntil(.visible)
        XCTAssertTrue(discussionDeepLink.isVisible)
        discussionDeepLink.hit()
        let discussionDetailsNavBar = DiscussionsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(discussionDetailsNavBar.isVisible)

        DiscussionsHelper.Details.backButton.hit()

        // MARK: Check deep link to announcement
        let announcementDeepLink = app.find(labelContaining: announcement.title).waitUntil(.visible)
        XCTAssertTrue(announcementDeepLink.isVisible)
        announcementDeepLink.hit()
        let announcementDetailsNavBar = AnnouncementsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(announcementDetailsNavBar.isVisible)
    }

    func testAddPage() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let newPageTitle = "New Test Page"
        let newPageContent = "Content of new test page."

        // MARK: Get the user logged in, navigate to Pages
        logInDSUser(teacher)
        PagesHelper.navigateToPages(course: course)

        // MARK: Add new page
        let addButton = PagesHelper.add.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)

        addButton.hit()
        let titleField = PagesHelper.Editor.title.waitUntil(.visible)
        let contentField = PagesHelper.Editor.content.waitUntil(.visible)
        let publishedToggle = PagesHelper.Editor.published.waitUntil(.visible)
        let doneButton = PagesHelper.Editor.done.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(contentField.isVisible)
        XCTAssertTrue(publishedToggle.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        titleField.writeText(text: newPageTitle)
        contentField.writeText(text: newPageContent)
        publishedToggle.hit()
        doneButton.hit()

        // MARK: Check if new page got added
        let newPageItem = PagesHelper.page(index: 0).waitUntil(.visible)
        XCTAssertTrue(newPageItem.isVisible)
        XCTAssertTrue(newPageItem.hasLabel(label: newPageTitle))
    }

    func testEditPage() {
        // MARK: Seed the usual stuff and a front page
        let teacher = seeder.createUser()
        let course = seeder.createCourse()

        let title = "Editable Page"
        let newTitle = "Edited Page"
        let body = "Test for editing page"
        PagesHelper.createPage(course: course, title: title, body: body, frontPage: true, published: true)

        // MARK: Enroll user in course, get user logged in
        seeder.enrollTeacher(teacher, in: course)
        logInDSUser(teacher)

        // MARK: Navigate to front page of course
        PagesHelper.navigateToFrontPage(course: course)

        let optionsButton = PagesHelper.Details.options.waitUntil(.visible)
        XCTAssertTrue(optionsButton.isVisible)

        optionsButton.hit()
        let editButton = PagesHelper.Details.editButton.waitUntil(.visible)
        XCTAssertTrue(editButton.isVisible)

        editButton.hit()
        let titleField = PagesHelper.Editor.title.waitUntil(.visible)
        let contentField = PagesHelper.Editor.content.waitUntil(.visible)
        let doneButton = PagesHelper.Editor.done.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(contentField.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        titleField.cutText()
        titleField.writeText(text: newTitle)
        doneButton.hit()

        // MARK: Check if edited page is updated
        let pageTitle = PagesHelper.titleByText(text: newTitle).waitUntil(.visible)
        XCTAssertTrue(pageTitle.isVisible)
    }
}
