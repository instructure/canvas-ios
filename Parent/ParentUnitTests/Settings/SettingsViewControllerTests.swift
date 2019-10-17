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

import Foundation
import XCTest
@testable import Parent
import TestsFoundation
@testable import Core

class SettingsViewControllerTests: ParentTestCase {
    var viewController: SettingsViewController!

    override func setUp() {
        super.setUp()
        viewController = SettingsViewController.create(env: env, session: legacySession!)
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testAddPairingCode() throws {
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), value: .make())
        load()
        viewController.viewWillAppear(false)
        let addStudentButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        XCTAssertEqual(addStudentButton.target as? SettingsViewController, viewController)
        XCTAssertEqual(addStudentButton.action, #selector(SettingsViewController.actionAddStudent))
        viewController.actionAddStudent()
        drainMainQueue()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        router.dismiss()
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        drainMainQueue()
        XCTAssertNil(router.presented, "Nothing presented so no error alert shown")
    }

    func testAddPairingCodeError() throws {
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), error: NSError.instructureError("Oops!"))
        load()
        viewController.viewWillAppear(false)
        let addStudentButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        XCTAssertEqual(addStudentButton.target as? SettingsViewController, viewController)
        XCTAssertEqual(addStudentButton.action, #selector(SettingsViewController.actionAddStudent))
        viewController.actionAddStudent()
        drainMainQueue()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        router.dismiss()
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        drainMainQueue()
        let error = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(error.message, "Oops!")
    }
}
