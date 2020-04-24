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
import XCTest
import TestsFoundation
@testable import Core
@testable import Parent

class AddStudentControllerTests: ParentTestCase {
    let mock = UIViewController()
    lazy var controller = AddStudentController(presentingViewController: mock) { _ in }

    func testLayout() throws {
        controller.actionAddStudent()

        let alert = try XCTUnwrap(router.presented as? UIAlertController)

        var action = alert.actions[1] as! AlertAction
        XCTAssertEqual(action.title, "Add")
        XCTAssertEqual(action.style, .default)

        action = alert.actions[0] as! AlertAction
        XCTAssertEqual(action.title, "Cancel")
        XCTAssertEqual(action.style, .cancel)

        let tf = alert.textFields?.first!
        XCTAssertEqual(tf!.placeholder, "Pairing Code")
    }

    func testAddPairingCode() throws {
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), value: .make())
        controller.actionAddStudent()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        router.dismiss()
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        XCTAssertNil(router.presented, "Nothing presented so no error alert shown")
    }

    func testAddPairingCodeError() throws {
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), error: NSError.instructureError("Oops!"))
        controller.actionAddStudent()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        router.dismiss()
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        let error = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(error.message, "Oops!")
    }
}
