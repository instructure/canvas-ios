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
import TestsFoundation

class EditComposeRecipientsViewControllerTests: CoreTestCase {
    var courseID = "1"
    var observeeID = "2"
    lazy var controller = EditComposeRecipientsViewController.create(
        context: .course(courseID),
        observeeID: observeeID,
        selectedRecipients: [.make(from: .make(id: "2", name: "B", full_name: "B", avatar_url: nil))]
    )
    var callbackController: EditComposeRecipientsViewController?

    func testLayout() {
        let teacher = APISearchRecipient.make(
            id: "2",
            name: "B",
            full_name: "B",
            common_courses: [courseID: ["TeacherEnrollment"]]
        )
        let teacher2 = APISearchRecipient.make(
            id: "3",
            name: "C",
            full_name: "C",
            common_courses: [courseID: ["TeacherEnrollment"]]
        )

        let ta = APISearchRecipient.make(
            id: "4",
            name: "D",
            full_name: "D",
            common_courses: [courseID: ["TaEnrollment"]]
        )
        api.mock(controller.teachers, value: [teacher, teacher2])
        api.mock(controller.tas, value: [ta])
        controller.delegate = self
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.tableView?.numberOfSections, 1)
        XCTAssertEqual(controller.tableView?.numberOfRows(inSection: 0), 3)
        var teacherCell = recipientCell(at: 0)
        XCTAssertEqual(teacherCell.avatarView.name, "B")
        XCTAssertEqual(teacherCell.nameLabel.text, "B")
        XCTAssertEqual(teacherCell.roleLabel.text, "Teacher")
        XCTAssertFalse(teacherCell.selectedView.isHidden)
        var teacher2Cell = recipientCell(at: 1)
        XCTAssertEqual(teacher2Cell.avatarView.name, "C")
        XCTAssertEqual(teacher2Cell.nameLabel.text, "C")
        XCTAssertEqual(teacher2Cell.roleLabel.text, "Teacher")
        XCTAssertTrue(teacher2Cell.selectedView.isHidden)
        let taCell = recipientCell(at: 2)
        XCTAssertEqual(taCell.avatarView.name, "D")
        XCTAssertEqual(taCell.nameLabel.text, "D")
        XCTAssertEqual(taCell.roleLabel.text, "TA")
        XCTAssertTrue(taCell.selectedView.isHidden)
        controller.tableView?.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        teacherCell = recipientCell(at: 0)
        XCTAssertTrue(teacherCell.selectedView.isHidden)
        controller.tableView?.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        teacher2Cell = recipientCell(at: 1)
        XCTAssertFalse(teacher2Cell.selectedView.isHidden)
        controller.viewWillDisappear(false)
        XCTAssertEqual(callbackController?.selectedRecipients.count, 1)
        XCTAssertEqual(callbackController?.selectedRecipients.first?.id, teacher2.id.value)
    }
}

extension EditComposeRecipientsViewControllerTests: EditComposeRecipientsViewControllerDelegate {
    func editRecipientsControllerDidFinish(_ controller: EditComposeRecipientsViewController) {
        callbackController = controller
    }
}

extension EditComposeRecipientsViewControllerTests {
    func recipientCell(at row: Int) -> RecipientCell {
        return controller.tableView.dataSource!.tableView(controller.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! RecipientCell
    }
}
