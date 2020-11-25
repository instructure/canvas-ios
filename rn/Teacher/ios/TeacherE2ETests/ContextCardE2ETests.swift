//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class ContextCardE2ETests: CoreUITestCase {
    override func setUp() {
        super.setUp()
        Dashboard.courseCard(id: "263").tapUntil {
            CourseNavigation.assignments.exists
        }
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1831").tap()
        AssignmentDetails.Submissions.gradedDial.tap()
        app.find(id: "submission-613").tap()
        app.find(id: "header.context.button.613").tap()
    }

    func testContextCardEmail() throws {
        try XCTSkipIf(Date() < Date(fromISOString: "2020-11-01T00:00:00Z")!, "blocked on https://instructure.atlassian.net/browse/INTEROP-6137")
        XCTAssertEqual(ContextCard.userEmailLabel.label(), "ios+student1@instructure.com")
    }

    func testContextCard() throws {
        XCTAssertEqual(ContextCard.userNameLabel.label(), "Student One")
//        XCTAssertEqual(ContextCard.userEmailLabel.label(), "ios+student1@instructure.com")
        XCTAssert(ContextCard.lastActivityLabel.label().hasPrefix("Last activity on "))
        XCTAssertEqual(ContextCard.courseLabel.label(), "Assignments")
        XCTAssertEqual(ContextCard.sectionLabel.label(), "Section: Assignments")
        XCTAssertEqual(ContextCard.currentGradeLabel.label(), "Current grade 72.73%")
        XCTAssertEqual(ContextCard.submissionsTotalLabel.label(), "Total Submissions 3")
        XCTAssertEqual(ContextCard.submissionsLateLabel.label(), "Late Submissions 0")
        XCTAssertEqual(ContextCard.submissionsMissingLabel.label(), "Missing Submissions 2")
        XCTAssertEqual(ContextCard.submissionCell("5431").label(), "Published, New Grade Book Quiz, Submitted, 1/1")
        XCTAssertEqual(ContextCard.submissionCell("1831").label(), "Published, Assignment One, Submitted, 7/10")
        XCTAssertEqual(ContextCard.submissionCell("261986").label(), "Published, Needs Grading, Submitted, NEEDS GRADING")
    }
}
