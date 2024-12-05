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

class SubmissionDetailsPickerTests: StudentTestCase {
    private let context = Context.course("1")

    override func setUp() {
        super.setUp()

        api.mock(GetAssignment(courseID: context.id, assignmentID: "1"), value: .make())
    }

    func testPickerHiddenWithTwoSubmissionsOneWithoutDate() {
        let submission = APISubmission.make(attempt: 1, submission_history: [
            .make(attempt: 0, submitted_at: nil)
        ], submitted_at: Date())
        api.mock(GetSubmission(context: context, assignmentID: "1", userID: "1"), value: submission)

        let testee = SubmissionDetailsViewController
            .create(env: env, context: context, assignmentID: "1", userID: "1")
        testee.loadViewIfNeeded()

        XCTAssertFalse(testee.pickerButton!.isEnabled)
    }

    func testPickerOffersOnlySubmissionsWithDate() {
        let submission = APISubmission.make(attempt: 2, submission_history: [
            .make(attempt: 1, submitted_at: Date()),
            .make(attempt: 0, submitted_at: nil)
        ], submitted_at: Date())
        api.mock(GetSubmission(context: context, assignmentID: "1", userID: "1"), value: submission)

        let testee = SubmissionDetailsViewController
            .create(env: env, context: context, assignmentID: "1", userID: "1")
        testee.loadViewIfNeeded()

        XCTAssertEqual(testee.picker!.dataSource?.pickerView(testee.picker!, numberOfRowsInComponent: 0), 2)
        let noSubmissionDateTitle = String(localized: "No Submission Date", bundle: .student)
        XCTAssertNotEqual(testee.picker!.delegate?.pickerView?(testee.picker!, titleForRow: 0, forComponent: 0), noSubmissionDateTitle)
        XCTAssertNotEqual(testee.picker!.delegate?.pickerView?(testee.picker!, titleForRow: 1, forComponent: 0), noSubmissionDateTitle)
    }
}
