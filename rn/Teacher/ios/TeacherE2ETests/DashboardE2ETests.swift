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

import XCTest
import TestsFoundation

class DashboardE2ETests: CoreUITestCase {
    func testDashboardE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1831").tap()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        XCTAssertTrue(Dashboard.courseCard(id: "263").exists())
        TabBar.inboxTab.tap()
        Inbox.filterButton.waitToExist()
        TabBar.dashboardTab.tap()
        XCTAssertTrue(Dashboard.courseCard(id: "263").exists())
        app.find(label: "Edit").tap()
        NavBar.backButton.tap()
        XCTAssertTrue(Dashboard.courseCard(id: "263").exists())
        XCTAssertTrue(Dashboard.courseCard(id: "5586").exists())
        XCTAssertTrue(Dashboard.courseCard(id: "892").exists())
        XCTAssertTrue(Dashboard.courseCard(id: "399").exists())
    }
}
