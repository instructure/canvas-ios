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

class DashboardTests: CoreUITests {
    override var abstractTestClass: CoreUITests.Type { return DashboardTests.self }

    func testAnnouncementBelowInvite() {
        CourseInvitation.acceptButton(id: "998").waitToExist()
        GlobalAnnouncement.toggle(id: "2").waitToExist()
        XCTAssertLessThan(CourseInvitation.acceptButton(id: "998").frame.maxY, GlobalAnnouncement.toggle(id: "2").frame.minY)
    }

    func testAnnouncementToggle() {
        let label = "This is a global announcement for students."
        GlobalAnnouncement.toggle(id: "2").waitToExist()
        XCTAssertFalse(GlobalAnnouncement.dismiss(id: "2").isVisible)
        XCTAssertFalse(app.find(label: label).isVisible)

        GlobalAnnouncement.toggle(id: "2").tap()
        GlobalAnnouncement.dismiss(id: "2").waitToExist()
        app.find(label: label).waitToExist()

        GlobalAnnouncement.toggle(id: "2").tap()
        GlobalAnnouncement.dismiss(id: "2").waitToVanish()
    }

    func testNavigateToDashboard() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.pages.tap()
        PagesList.frontPage.tap()

        TabBar.dashboardTab.tap()
        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()
    }

    func testCourseCardInfo() {
        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(Dashboard.courseCard(id: "263").label, "Assignments")
    }

    func testSeeAllButtonDisplaysCorrectCourses() {
        Dashboard.seeAllButton.tap()

        // expired course and others should be listed
        Dashboard.courseCard(id: "303").waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()

        // Invite Only should not be listed
        Dashboard.courseCard(id: "338").waitToVanish()
    }
}

class DashboardEmptyTests: CoreUITests {
    override var abstractTestClass: CoreUITests.Type { return DashboardEmptyTests.self }
    override var user: UITestUser { return .notEnrolled }

    func testEmptyCanAddCourses() {
        Dashboard.emptyTitleLabel.waitToExist()
        XCTAssertEqual(Dashboard.emptyTitleLabel.label, "Welcome!")
        Dashboard.addCoursesButton.tap()
        app.find(label: "Edit Dashboard").waitToExist()
    }
}
