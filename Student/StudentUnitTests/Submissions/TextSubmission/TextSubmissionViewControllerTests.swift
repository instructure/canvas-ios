//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Student
import TestsFoundation

class TextSubmissionViewControllerTests: StudentTestCase {
    var controller: TextSubmissionViewController!
    var navigation: UINavigationController!

    let request = CreateSubmissionRequest(context: .course("1"), assignmentID: "1", body: .init(submission: .init(
        group_comment: nil,
        submission_type: .online_text_entry,
        body: "<b>submission</b>"
    )))

    class MockEditor: RichContentEditorViewController {
        override func getHTML(_ callback: @escaping (String) -> Void) {
            callback("<b>submission</b>")
        }
    }

    override func setUp() {
        super.setUp()
        controller = TextSubmissionViewController.create(courseID: "1", assignmentID: "1", userID: "1")
        controller.editor = MockEditor()
        controller.editor.env = env
        navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
    }

    func testLayout() {
        controller.viewDidAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertEqual(controller.title, "Text Entry")
        XCTAssertEqual(navigation.navigationBar.barTintColor, .backgroundLightest)
        XCTAssertNotNil(controller.keyboard)
    }

    func testRCEError() {
        controller.rce(controller.editor, didError: NSError.instructureError("bwoke"))
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "bwoke")
    }

    func testSubmitError() {
        api.mock(request, error: NSError.instructureError("Oops"))
        let submit = controller.navigationItem.rightBarButtonItem!
        _ = submit.target?.perform(submit.action)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")
    }

    func testSubmitSuccess() {
        api.mock(request, value: .make())
        controller.rce(controller.editor, canSubmit: true)
        let submit = controller.navigationItem.rightBarButtonItem!
        XCTAssertTrue(submit.isEnabled)
        _ = submit.target?.perform(submit.action)
        XCTAssertNil(router.presented)
    }
}
