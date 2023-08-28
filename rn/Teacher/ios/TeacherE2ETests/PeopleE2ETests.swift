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

class PeopleE2ETests: CoreUITestCase {
    func testPeopleE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .people).hit()
        app.find(label: "Student One").hit()
        XCTAssertTrue(app.find(labelContaining: "Assignments").waitUntil(.visible).isVisible)
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.waitUntil(.visible).label, "3 submitted")
        PeopleHelper.backButton.hit()
        app.find(label: "Student Two").hit()
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsMissingLabel.waitUntil(.visible).label, "1 missing")
        PeopleHelper.backButton.hit()
        app.find(label: "Filter").hit()
        app.find(label: "Teachers").hit()
        app.swipeDown()
        XCTAssertFalse(app.find(label: "Student One").waitUntil(.vanish).isVisible)
        XCTAssertTrue(app.find(label: "Teacher One").waitUntil(.visible).isVisible)
    }
}
