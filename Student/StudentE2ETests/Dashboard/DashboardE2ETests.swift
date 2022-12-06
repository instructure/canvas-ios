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

class DashboardE2ETests: CoreUITestCase {
    func testAnnouncementBelowInvite() {
        CourseInvitation.acceptButton(id: "998").waitToExist()
        AccountNotifications.toggleButton(id: "2").waitToExist()
        XCTAssertLessThan(CourseInvitation.acceptButton(id: "998").frame().maxY, AccountNotifications.toggleButton(id: "2").frame().minY)
    }

    func testNavigateToDashboard() throws {
        try XCTSkipIf(true, "passes locally but fails on bitrise")
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.pages.tap()
        PageList.frontPage.tap()

        TabBar.dashboardTab.tap()
        Dashboard.coursesLabel.waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()
    }

    func testCourseCardInfo() {
        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(Dashboard.courseCard(id: "263").label(), "Assignments assignments")
    }

    func testSeeAllButtonDisplaysCorrectCourses() throws {
        try XCTSkipIf(true, "passes locally but fails on bitrise")
        Dashboard.editButton.tap()

        // expired course and others should be listed
        Dashboard.courseCard(id: "303").waitToExist()
        Dashboard.courseCard(id: "247").waitToExist()
        Dashboard.courseCard(id: "262").waitToExist()
        Dashboard.courseCard(id: "263").waitToExist()

        // Invite Only should not be listed
        Dashboard.courseCard(id: "338").waitToVanish()
    }

    func testCourseCardGrades() {
        Dashboard.dashboardSettings().waitToExist(10).tap()
        Dashboard.dashboardSettingsShowGradeToggle().waitToExist(10)
        if !Dashboard.dashboardSettingsShowGradeToggle().isSelected {
            Dashboard.dashboardSettingsShowGradeToggle().tap()
        }
        app.find(label: "Done").tap()
        pullToRefresh()
        Dashboard.courseCard(id: "263").waitToExist(5)
        XCTAssertEqual(Dashboard.courseCard(id: "263").label(), "Assignments assignments 72.73%")

        Dashboard.dashboardSettings().waitToExist(5).tap()
        Dashboard.dashboardSettingsShowGradeToggle().waitToExist(5).tap()
        app.find(label: "Done").tap()
        Dashboard.courseCard(id: "263").waitToExist(5)

        XCTAssertEqual(Dashboard.courseCard(id: "263").label().trimmingCharacters(in: .whitespacesAndNewlines), "Assignments assignments")
    }
}
