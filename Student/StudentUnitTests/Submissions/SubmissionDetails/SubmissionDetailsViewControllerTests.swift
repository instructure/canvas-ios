//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class SubmissionDetailsViewControllerTests: StudentTestCase {
    lazy var controller = SubmissionDetailsViewController
        .create(
            env: env,
            context: .course("1"),
            assignmentID: "1",
            userID: "1"
        )

    func testKeyboardShown() {
        controller.view.layoutIfNeeded()
        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: [:])
        XCTAssertEqual(controller.drawer?.height, controller.drawer?.maxDrawerHeight)
    }

    func testSelectsReceivedAttempt() {
        // GIVEN
        Assignment.make()
        Submission.make(from: .make(attempt: 1, id: "1", score: 1))
        Submission.make(from: .make(attempt: 7, id: "2", score: 2))

        // WHEN
        let testee = SubmissionDetailsViewController
            .create(
                env: env,
                context: .course("1"),
                assignmentID: "1",
                userID: "1",
                selectedAttempt: 1
            )
        testee.loadViewIfNeeded()

        // THEN
        XCTAssertEqual(testee.presenter?.selectedAttempt, 1)
        XCTAssertEqual(testee.presenter?.pickerSubmissions[1].attempt, 1)
    }
}
