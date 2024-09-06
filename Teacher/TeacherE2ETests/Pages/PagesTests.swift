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
    typealias Helper = PagesHelper
    typealias DetailsHelper = Helper.Details
    typealias EditorHelper = Helper.Editor

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

        // MARK: Check pages button
        courseCard.hit()
        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        XCTAssertTrue(pagesButton.isVisible)

        // MARK: Check front page button
        pagesButton.hit()
        let frontPageButton = Helper.frontPage.waitUntil(.visible)
        XCTAssertTrue(frontPageButton.isVisible)

        // MARK: Check title of front page
        frontPageButton.hit()
        let frontPageTitle = Helper.titleByText(text: frontPage.title).waitUntil(.visible)
        XCTAssertTrue(frontPageTitle.isVisible)
    }

    func testDeepLinks() {
        // MARK: Seed the usual stuff and a front page containing some deep links
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let assignmentName = "Deep Link Assignment"
        let assignment = AssignmentsHelper.createAssignment(course: course, name: assignmentName)
        let assignmentLink = Helper.createLinkToAssignment(course: course, assignment: assignment)

        let discussionTitle = "Deep Link Discussion"
        let discussion = DiscussionsHelper.createDiscussion(course: course, title: discussionTitle)
        let discussionLink = Helper.createLinkToDiscussion(course: course, discussion: discussion)

        let announcementTitle = "Deep Link Announcement"
        let announcement = DiscussionsHelper.createDiscussion(course: course, title: announcementTitle, isAnnouncement: true)
        let announcementLink = Helper.createLinkToDiscussion(course: course, discussion: announcement)

        let body = "\(assignmentLink)\n\(discussionLink)\n\(announcementLink)"
        Helper.createDeepLinkFrontPage(course: course, body: body)

        // MARK: Enroll user in course, get user logged in
        seeder.enrollTeacher(teacher, in: course)
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to front page of course
        Helper.navigateToFrontPage(course: course)

        // MARK: Check deep link to assignment
        let assignmentDeepLink = app.find(labelContaining: assignment.name).waitUntil(.visible)
        XCTAssertTrue(assignmentDeepLink.isVisible)

        assignmentDeepLink.hit()
        let assignmentDetailsNameLabel = AssignmentsHelper.Details.name.waitUntil(.visible)
        XCTAssertTrue(assignmentDetailsNameLabel.isVisible)

        // MARK: Check deep link to discussion
        AssignmentsHelper.Details.backButton.hit()
        let discussionDeepLink = app.find(labelContaining: discussion.title).waitUntil(.visible)
        XCTAssertTrue(discussionDeepLink.isVisible)

        discussionDeepLink.hit()
        let discussionDetailsTitle = DiscussionsHelper.NewDetails.discussionTitle(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionDetailsTitle.isVisible)

        // MARK: Check deep link to announcement
        DiscussionsHelper.Details.backButton.hit()
        let announcementDeepLink = app.find(labelContaining: announcement.title).waitUntil(.visible)
        XCTAssertTrue(announcementDeepLink.isVisible)

        announcementDeepLink.hit()
        let announcementDetailsTitle = DiscussionsHelper.NewDetails.discussionTitle(discussion: announcement).waitUntil(.visible)
        XCTAssertTrue(announcementDetailsTitle.isVisible)
    }

    func testAddPage() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let newPageTitle = "New Test Page"
        let newPageContent = "Content of new test page."

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Pages, Add new page
        Helper.navigateToPages(course: course)
        let addButton = Helper.add.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)

        addButton.hit()
        let titleField = EditorHelper.title.waitUntil(.visible)
        let contentField = EditorHelper.content.waitUntil(.visible)
        let publishedToggle = EditorHelper.published.waitUntil(.visible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(contentField.isVisible)
        XCTAssertTrue(publishedToggle.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        titleField.writeText(text: newPageTitle)
        contentField.writeText(text: newPageContent)
        publishedToggle.hit()
        doneButton.hit()

        // MARK: Check if new page got added
        let newPageItem = Helper.page(index: 0).waitUntil(.visible)
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
        Helper.createPage(course: course, title: title, body: body, frontPage: true, published: true)

        // MARK: Enroll user in course, get user logged in
        seeder.enrollTeacher(teacher, in: course)
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to front page of course
        Helper.navigateToFrontPage(course: course)
        let optionsButton = DetailsHelper.options.waitUntil(.visible)
        XCTAssertTrue(optionsButton.isVisible)

        optionsButton.hit()
        let editButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(editButton.isVisible)

        editButton.hit()
        let titleField = EditorHelper.title.waitUntil(.visible)
        let contentField = EditorHelper.content.waitUntil(.visible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(contentField.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        titleField.cutText()
        titleField.writeText(text: newTitle)
        doneButton.hit()

        // MARK: Check if edited page is updated
        let pageTitle = Helper.titleByText(text: newTitle).waitUntil(.visible)
        XCTAssertTrue(pageTitle.isVisible)
    }
}
