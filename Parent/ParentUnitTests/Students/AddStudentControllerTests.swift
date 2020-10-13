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
    class MockViewController: UIViewController, ErrorViewController {}
    let mock = MockViewController()
    lazy var controller = AddStudentController(presentingViewController: mock) { _ in }

    func testAddPairingCodeInput() throws {
        let expectation = XCTestExpectation(description: "handler was called")
        controller.handler = { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), value: .make())
        controller.addStudent()
        let picker = router.presented as! BottomSheetPickerViewController
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "QR Code")
        XCTAssertEqual(picker.actions[1].title, "Pairing Code")
        picker.actions[1].action()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        wait(for: [expectation], timeout: 1)
    }

    func testAddPairingCodeError() throws {
        let expectation = XCTestExpectation(description: "handler was called")
        controller.handler = { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        let error = NSError.internalError()
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), error: error)
        controller.addStudent()
        let picker = router.presented as! BottomSheetPickerViewController
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "QR Code")
        XCTAssertEqual(picker.actions[1].title, "Pairing Code")
        picker.actions[1].action()
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        let textField = try XCTUnwrap(alert.textFields?.first)
        textField.text = "abc"
        let add = try XCTUnwrap(alert.actions.first { $0.title == "Add" } as? AlertAction)
        add.handler?(add)
        wait(for: [expectation], timeout: 1)
        let errorAlert = router.presented as! UIAlertController
        XCTAssertEqual(errorAlert.message, error.localizedDescription)
    }

    func testScanQRCode() {
        let expectation = XCTestExpectation(description: "handler was called")
        controller.handler = { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        let code = "canvas-parent://canvas.instructure.com/pair?code=code"
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), value: .make())
        controller.addStudent()
        let picker = router.presented as! BottomSheetPickerViewController
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "QR Code")
        XCTAssertEqual(picker.actions[1].title, "Pairing Code")
        picker.actions[0].action()
        let scanner = router.presented as! ScannerViewController
        scanner.delegate?.scanner(ScannerViewController(), didScanCode: code)
        wait(for: [expectation], timeout: 1)
    }

    func testScannerDomainMismatch() {
        let expectation = XCTestExpectation(description: "handler was called")
        controller.handler = { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        let code = "canvas-parent://twilson.instructure.com/pair?code=code"
        api.mock(PostObserveesRequest(userID: "self", pairingCode: "abc"), value: .make())
        controller.addStudent()
        let picker = router.presented as! BottomSheetPickerViewController
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "QR Code")
        XCTAssertEqual(picker.actions[1].title, "Pairing Code")
        picker.actions[0].action()
        let scanner = router.presented as! ScannerViewController
        scanner.delegate?.scanner(ScannerViewController(), didScanCode: code)
        let alert = router.presented as! UIAlertController
        XCTAssertEqual(alert.title, "Domain mismatch")
        let msg = "The student you are trying to add is at a different Canvas institution.\nSign in or create an account with that institution to add this student."
        XCTAssertEqual(alert.message, msg)

    }
}
