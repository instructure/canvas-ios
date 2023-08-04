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

import TestsFoundation

class DashboardE2ETests: CoreUITestCase {
    func testDashboardE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .assignments).hit()
        AssignmentsHelper.assignmentButton(assignmentId: "1831").hit()
        DashboardHelper.backButton.hit()
        DashboardHelper.backButton.hit()
        DashboardHelper.backButton.hit()
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "263").waitUntil(.visible).isVisible)
        DashboardHelper.TabBar.inboxTab.hit()
        InboxHelper.Filter.byCourse.waitUntil(.visible)
        DashboardHelper.TabBar.dashboardTab.hit()
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "263").waitUntil(.visible).isVisible)
        app.find(label: "Edit").hit()
        DashboardHelper.backButton.hit()
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "263").waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "5586").waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "892").waitUntil(.visible).isVisible)
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "399").waitUntil(.visible).isVisible)
    }
}
