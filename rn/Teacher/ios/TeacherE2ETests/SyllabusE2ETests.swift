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

class SyllabusE2ETests: CoreUITestCase {
    func testSyllabusE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.syllabus.tap()
        app.find(labelContaining: "Graded Discussion").tap()
        AssignmentDetails.description("Why does Xcode come with a black version of its icon?").waitToExist()
        NavBar.backButton.tap()
        app.find(labelContaining: "Past Due").waitToExist()
        app.find(label: "Edit").tap()
        app.find(labelContaining: "Show Course Summary").waitToExist()
        app.find(label: "Cancel").tap()
        app.find(labelContaining: "Assignment One").waitToExist()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        Dashboard.courseCard(id: "263").waitToExist()
    }
}
