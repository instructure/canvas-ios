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
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .assignments).hit()
        AssignmentsHelper.assignmentButton(assignmentId: "1831").hit()
        // Simulate a tap on the "Graded" circle since it's not visible to accessibility because it's a button inside another button
        AssignmentsHelper.Details.viewAllSubmissionsButton.tapAt(CGPoint(x: 50, y: 50))
        app.find(id: "SubmissionListCell.613").hit()
        AssignmentsHelper.SpeedGrader.userButton.hit()
    }

    func testContextCard() throws {
        XCTAssertEqual(PeopleHelper.ContextCard.userNameLabel.label, "Student One")
        XCTAssertEqual(PeopleHelper.ContextCard.userEmailLabel.label, "ios+student1@instructure.com")
        XCTAssert(PeopleHelper.ContextCard.lastActivityLabel.label.hasPrefix("Last activity on "))
        XCTAssertEqual(PeopleHelper.ContextCard.courseLabel.label, "Assignments")
        XCTAssertEqual(PeopleHelper.ContextCard.sectionLabel.label, "Section: Assignments")
        XCTAssertEqual(PeopleHelper.ContextCard.currentGradeLabel.label, "Current Grade 72.73%")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsTotalLabel.label, "3 submitted")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsLateLabel.label, "0 late")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionsMissingLabel.label, "0 missing")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "5431").label,
                       "Submission New Grade Book Quiz, Submitted, grade 1 / 1")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "1831").label,
                       "Submission Assignment One, Submitted, grade 7 / 10")
        XCTAssertEqual(PeopleHelper.ContextCard.submissionCell(assignmentId: "261986").label,
                       "Submission Needs Grading, Submitted, NEEDS GRADING")
    }
}
