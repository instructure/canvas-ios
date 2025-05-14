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

import Foundation
@testable import Core
@testable import TestsFoundation
@testable import Student
import XCTest

class SubmissionCommentsViewControllerTests: StudentTestCase {
    var context = Context(.course, id: "1")
    var assignmentID  = "2"
    var userID = "3"
    var submissionID = "4"
    lazy var submissionPresenter: SubmissionDetailsPresenter = SubmissionDetailsPresenter(
        env: env,
        view: DummyView(),
        context: context,
        assignmentID: assignmentID,
        userID: userID
    )
    lazy var controller: SubmissionCommentsViewController = SubmissionCommentsViewController.create(
        env: env,
        context: context,
        assignmentID: assignmentID,
        userID: userID,
        submissionID: submissionID,
        submissionPresenter: submissionPresenter
    )
    var tableView: UITableView {
        return controller.tableView!
    }

    func testLayout() {
        Clock.mockNow(Date())
        api.mock(controller.presenter!.commentsStore, value: .make(
            assignment_id: assignmentID,
            attempt: 1,
            id: submissionID,
            submission_comments: [
                .make(
                    id: "1",
                    author: .make(display_name: "Jane Doe (She/Her)", pronouns: nil),
                    comment: "This is a comment",
                    created_at: Clock.now.addDays(-1)
                ),
                .make(
                    id: "2",
                    author: .make(display_name: "Ron Burgandy", pronouns: nil),
                    comment: "This is a comment",
                    created_at: Clock.now.addDays(-2)
                )
            ],
            submission_type: .online_upload,
            user: .make(short_name: "John Smith", pronouns: "He/Him"),
            user_id: userID
        ))
        api.mock(controller.presenter!.assignment, value: .make(
            course_id: ID(context.id),
            id: ID(assignmentID)
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 6)
        XCTAssertEqual(headerCell(atRow: 1).authorNameLabel?.text, "Jane Doe (She/Her)")
        XCTAssertEqual(headerCell(atRow: 3).authorNameLabel?.text, "Ron Burgandy")
        XCTAssertEqual(headerCell(atRow: 5).authorNameLabel?.text, "John Smith (He/Him)")

        Clock.reset()
    }
}

extension SubmissionCommentsViewControllerTests {
    func headerCell(atRow row: Int) -> SubmissionCommentHeaderCell {
        return cell(atRow: row)
    }

    func attemptCell(atRow row: Int) -> SubmissionCommentAttemptCell {
        return cell(atRow: row)
    }

    func cell<T>(atRow row: Int) -> T where T: UITableViewCell {
        return tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! T
    }
}

private class DummyView: UIViewController, SubmissionDetailsViewProtocol {
    func reload() {}
    func reloadNavBar() {}
    func embed(_ controller: UIViewController?) {}
    func embedInDrawer(_ controller: UIViewController?) {}
    var color: UIColor?
    var titleSubtitleView = TitleSubtitleView()
}
