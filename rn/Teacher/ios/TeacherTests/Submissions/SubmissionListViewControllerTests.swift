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
@testable import Core
@testable import Teacher

class SubmissionListViewControllerTests: TeacherTestCase {
    lazy var controller = SubmissionListViewController.create(context: .course("1"), assignmentID: "1", filter: [])

    override func setUp() {
        super.setUp()
        api.mock(controller.assignment, value: .make())
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(controller.course, value: .make())
        api.mock(controller.enrollments, value: [
            .make(id: "1", course_id: "1", course_section_id: "1", user_id: "1"),
            .make(id: "2", course_id: "1", course_section_id: "2", user_id: "2"),
            .make(id: "3", course_id: "1", course_section_id: "2", enrollment_state: .inactive, user_id: "3"),
            .make(id: "4", course_id: "1", course_section_id: "3", user_id: "4", role: "CustomEnrollment"),
        ])
        api.mock(controller.sections, value: [
            .make(id: "1", name: "One"),
            .make(id: "2", name: "Two"),
            .make(id: "3", name: "Three"),
        ])
        api.mock(controller.submissions, value: [
            .make(
                submission_history: [],
                submission_type: .online_text_entry,
                user: .make(sortable_name: "Bob"),
                workflow_state: .pending_review
            ),
            .make(
                submission_history: [],
                user: .make(id: "2", name: "Alice", sortable_name: "Alice"),
                user_id: "2"
            ),
            .make(
                submission_history: [],
                submitted_at: nil,
                user: .make(id: "3", name: "Christine", sortable_name: "Christine"),
                user_id: "3",
                workflow_state: .unsubmitted
            ),
            .make(
                submission_history: [],
                submitted_at: nil,
                user: .make(id: "4", name: "Rebecca", sortable_name: "Rebecca"),
                user_id: "4",
                workflow_state: .unsubmitted
            ),
        ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        XCTAssertEqual(controller.titleSubtitleView.title, "Submissions")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "some assignment")
        XCTAssertEqual(nav.navigationBar.barTintColor!.hexString, UIColor(hexString: "#f00")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.count, 2)

        var cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SubmissionListCell
        XCTAssertEqual(cell?.nameLabel.text, "Alice")
        XCTAssertEqual(cell?.statusLabel.text, "Submitted")
        XCTAssertEqual(cell?.needsGradingView.isHidden, true)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SubmissionListCell
        XCTAssertEqual(cell?.nameLabel.text, "Bob")
        XCTAssertEqual(cell?.statusLabel.text, "Submitted")
        XCTAssertEqual(cell?.needsGradingView.isHidden, false)

        cell = controller.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SubmissionListCell
        XCTAssertNil(cell)

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/1/submissions/2"))

        controller.showFilters()
        let picker = router.presented as? SubmissionFilterPickerViewController
        picker?.onChange([ .section([ "1", "2" ]) ])
        XCTAssertEqual(controller.filter, [ .section([ "1", "2" ]) ])

        picker?.onChange([ .section(["3"]), .notSubmitted ])
        XCTAssertEqual(controller.filter, [ .section(["3"]), .notSubmitted ])
        cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SubmissionListCell
        XCTAssertEqual(cell?.nameLabel.text, "Rebecca")
        XCTAssertEqual(cell?.statusLabel.text?.lowercased(), "Not Submitted".lowercased())
        XCTAssertEqual(cell?.needsGradingView.isHidden, true)

        api.mock(controller.submissions, error: NSError.internalError())
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, false)

        api.mock(controller.submissions, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.errorView.isHidden, true)
        XCTAssertEqual(controller.emptyView.isHidden, false)

        _ = controller.postPolicyButton.target?.perform(controller.postPolicyButton.action)
        XCTAssert(router.lastRoutedTo("/courses/1/assignments/1/post_policy", withOptions: .modal(embedInNav: true)))

        _ = controller.messageUsersButton.target?.perform(controller.messageUsersButton.action)
        XCTAssert(router.lastRoutedTo("/conversations/compose", withOptions: .modal(embedInNav: true)))

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testCell() {
        api.mock(controller.assignment, value: .make(anonymize_students: true))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.count, 1) // no message for anonymous
        let assigment = controller.assignment.first
        let submission = controller.submissions.first
        let cell = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SubmissionListCell

        assigment?.anonymizeStudents = true
        cell?.update(assigment, submission: submission)
        XCTAssertEqual(cell?.nameLabel.text, "Student")

        submission?.groupID = "1"
        cell?.update(assigment, submission: submission)
        XCTAssertEqual(cell?.nameLabel.text, "Group")

        assigment?.anonymizeStudents = false
        submission?.groupName = "Group One"
        cell?.update(assigment, submission: submission)
        XCTAssertEqual(cell?.nameLabel.text, "Group One")

        submission?.groupID = nil
        submission?.groupName = nil
        submission?.user?.name = "Alice"
        submission?.user?.pronouns = "She/Her"
        cell?.update(assigment, submission: submission)
        XCTAssertEqual(cell?.nameLabel.text, "Alice (She/Her)")
    }
}
