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

import XCTest
@testable import Student
@testable import Core
import TestsFoundation

class SubmissionDetailsPickerTests: StudentTestCase {
    private let context = Context.course("1")
    private let assignment = APIAssignment.make()
    private let APISubmissionWithoutDate = APISubmission.make(assignment_id: "1", attempt: 0, submitted_at: nil, user_id: "1")
    private let APISubmissionWithDate = APISubmission.make(assignment_id: "1", attempt: 1, submitted_at: Date(), user_id: "1")
    private let APISubmissionWithDate_2 = APISubmission.make(assignment_id: "1", attempt: 2, submitted_at: Date(), user_id: "1")

    override func setUp() {
        super.setUp()

        let getAssignment = GetAssignment(courseID: context.id, assignmentID: "1")
        getAssignment.write(response: assignment, urlResponse: nil, to: databaseClient)
        api.mock(getAssignment)
    }

    func testPickerHiddenWithTwoSubmissionsOneWithoutDate() {
        let mockGetSubmission = GetSubmission(context: context, assignmentID: "1", userID: "1")
        mockGetSubmission.write(response: APISubmissionWithoutDate, urlResponse: nil, to: databaseClient)
        mockGetSubmission.write(response: APISubmissionWithDate, urlResponse: nil, to: databaseClient)
        api.mock(mockGetSubmission)

        let testee = SubmissionDetailsViewController.create(context: context, assignmentID: "1", userID: "1")
        testee.loadViewIfNeeded()

        XCTAssertTrue(testee.pickerButtonArrow!.isHidden)
        XCTAssertFalse(testee.pickerButton!.isEnabled)
    }

    func testPickerOffersOnlySubmissionsWithDate() {
        let mockGetSubmission = GetSubmission(context: context, assignmentID: "1", userID: "1")
        mockGetSubmission.write(response: APISubmissionWithoutDate, urlResponse: nil, to: databaseClient)
        mockGetSubmission.write(response: APISubmissionWithDate, urlResponse: nil, to: databaseClient)
        mockGetSubmission.write(response: APISubmissionWithDate_2, urlResponse: nil, to: databaseClient)
        api.mock(mockGetSubmission)

        let testee = SubmissionDetailsViewController.create(context: context, assignmentID: "1", userID: "1")
        testee.loadViewIfNeeded()

        XCTAssertEqual(testee.picker!.dataSource?.pickerView(testee.picker!, numberOfRowsInComponent: 0), 2)
        let noSubmissionDateTitle = NSLocalizedString("No Submission Date", bundle: .student, comment: "")
        XCTAssertNotEqual(testee.picker!.delegate?.pickerView?(testee.picker!, titleForRow: 0, forComponent: 0), noSubmissionDateTitle)
        XCTAssertNotEqual(testee.picker!.delegate?.pickerView?(testee.picker!, titleForRow: 1, forComponent: 0), noSubmissionDateTitle)
    }
}
