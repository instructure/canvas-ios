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

class PeopleE2ETests: CoreUITestCase {
    func testPeopleE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.people.tap()
        app.find(label: "Student One").tap()
        app.find(labelContaining: "Assignments").waitToExist()
        XCTAssertEqual(ContextCard.submissionsTotalLabel.label(), "3 submitted")
        NavBar.backButton.tap()
        app.find(label: "Student Two").tap()
        XCTAssertEqual(ContextCard.submissionsMissingLabel.label(), "1 missing")
        NavBar.backButton.tap()
        app.find(label: "Filter").tap()
        app.find(label: "Teachers").tap()
        app.swipeDown()
        XCTAssertFalse(app.find(label: "Student One").exists())
        XCTAssertTrue(app.find(label: "Teacher One").exists())
    }
}
