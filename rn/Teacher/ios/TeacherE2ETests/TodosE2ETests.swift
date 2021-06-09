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

class TodosE2ETests: CoreUITestCase {
    func testTodosE2E() {
        let oneNeedsGradingLabel = "1 NEEDS GRADING"
        let needsGradingLabel = "Needs Grading"
        let todoBadgeValue = "1 item"

        Dashboard.courseCard(id: "263").waitToExist()
        XCTAssertEqual(TabBar.todoTab.value(), todoBadgeValue)
        TabBar.todoTab.tap()
        XCTAssertTrue(app.find(labelContaining: oneNeedsGradingLabel).exists())
        app.find(label: needsGradingLabel).tap()
        SpeedGrader.doneButton.tap()
        TabBar.dashboardTab.tap()
        TabBar.todoTab.tap()
        XCTAssertEqual(TabBar.todoTab.value(), todoBadgeValue)
        XCTAssertTrue(app.find(label: oneNeedsGradingLabel).exists())
    }
}
