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
@testable import Parent
@testable import CanvasCore
import TestsFoundation

class AssignmentDetailsViewControllerTests: ParentTestCase {

    var vc: AssignmentDetailsViewController!
    let courseID = "1"
    let studentID = "1"
    let assignmentID = "1"

    override func setUp() {
        super.setUp()
        vc = try! AssignmentDetailsViewController(session: Session.current!, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    }

    func render() {
        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)
        vc.viewDidAppear(false)
    }

    func testInboxReplyButton() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make())
        api.mock(GetAssignment(courseID: courseID, assignmentID: assignmentID), value: .make())
        api.mock(GetSearchRecipients(context: .course(courseID), userID: "1"), value: [.make()])

        render()

        XCTAssertNotNil(vc.replyButton)
        vc.replyButton?.sendActions(for: .primaryActionTriggered)
        let compose = router.presented as? ComposeViewController
        XCTAssertEqual(compose?.context.id, courseID)
        XCTAssertEqual(compose?.subjectField.text, "Regarding: John Doe, Assignment - some assignment")
        XCTAssertEqual(compose?.hiddenMessage, "Regarding: John Doe, https://canvas.instructure.com/courses/1/assignments/1")
    }
}
