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

class GradesE2ETests: CoreUITestCase {
    func testGradesE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .people).hit()
        app.find(label: "Student One").hit()
        XCTAssertEqual(PeopleHelper.ContextCard.courseLabel.waitUntil(.visible).label, "Assignments")
        XCTAssertEqual(PeopleHelper.ContextCard.currentGradeLabel.waitUntil(.visible).label, "Current Grade 72.73%")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.waitUntil(.visible).label, "3 submitted")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "5431").waitUntil(.visible).label,
                       "Submission New Grade Book Quiz, Submitted, grade 1 / 1")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "1831").waitUntil(.visible).label,
                       "Submission Assignment One, Submitted, grade 7 / 10")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "261986").waitUntil(.visible).label,
                       "Submission Needs Grading, Submitted, NEEDS GRADING")
        GradesHelper.backButton.hit()
        app.find(label: "Student Two").hit()
        XCTAssertEqual(PeopleHelper.ContextCard.courseLabel.waitUntil(.visible).label, "Assignments")
        XCTAssertEqual(PeopleHelper.ContextCard.currentGradeLabel.waitUntil(.visible).label, "Current Grade 0.0%")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsMissingLabel.waitUntil(.visible).label, "2 missing")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.waitUntil(.visible).label, "0 submitted")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "5431").waitUntil(.visible).label,
                       "Submission New Grade Book Quiz, Not Submitted, grade 0 / 1")
    }
}
