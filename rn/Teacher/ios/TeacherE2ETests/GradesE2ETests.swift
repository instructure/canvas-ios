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

class GradesE2ETests: CoreUITestCase {
    func testGradesE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.people.tap()
        app.find(label: "Student One").tap()
        XCTAssertEqual(ContextCard.courseLabel.label(), "Assignments")
        XCTAssertEqual(ContextCard.currentGradeLabel.label(), "Current Grade 72.73%")
        XCTAssertEqual(ContextCard.submissionsTotalLabel.label(), "3 submitted")
        XCTAssertEqual(ContextCard.submissionCell("5431").label(), "Submission New Grade Book Quiz, Submitted, grade 1 / 1")
        XCTAssertEqual(ContextCard.submissionCell("1831").label(), "Submission Assignment One, Submitted, grade 7 / 10")
        XCTAssertEqual(ContextCard.submissionCell("261986").label(), "Submission Needs Grading, Submitted, NEEDS GRADING")
        NavBar.backButton.tap()
        app.find(label: "Student Two").tap()
        XCTAssertEqual(ContextCard.courseLabel.label(), "Assignments")
        XCTAssertEqual(ContextCard.currentGradeLabel.label(), "Current Grade 0.0%")
        XCTAssertEqual(ContextCard.submissionsMissingLabel.label(), "2 missing")
        XCTAssertEqual(ContextCard.submissionsTotalLabel.label(), "0 submitted")
        XCTAssertEqual(ContextCard.submissionCell("5431").label(), "Submission New Grade Book Quiz, Not Submitted, grade 0 / 1")
    }
}
