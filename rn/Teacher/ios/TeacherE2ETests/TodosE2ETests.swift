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

class TodosE2ETests: CoreUITestCase {
    func testTodosE2E() {
        let oneNeedsGradingLabel = "1 NEEDS GRADING"
        let needsGradingLabel = "Needs Grading"
        let todoBadgeValue = "1 item"

        DashboardHelper.courseCard(courseId: "263").waitUntil(.visible)
        XCTAssertTrue(DashboardHelper.TabBar.todoTab.waitUntil(.visible).hasValue(value: todoBadgeValue))
        DashboardHelper.TabBar.todoTab.hit()
        XCTAssertTrue(app.find(labelContaining: oneNeedsGradingLabel).waitUntil(.visible).isVisible)
        app.find(label: needsGradingLabel).hit()
        AssignmentsHelper.SpeedGrader.doneButton.hit()
        DashboardHelper.TabBar.dashboardTab.hit()
        DashboardHelper.TabBar.todoTab.hit()
        XCTAssertTrue(DashboardHelper.TabBar.todoTab.waitUntil(.visible).hasValue(value: todoBadgeValue))
        XCTAssertTrue(app.find(label: oneNeedsGradingLabel).waitUntil(.visible).isVisible)
    }
}
