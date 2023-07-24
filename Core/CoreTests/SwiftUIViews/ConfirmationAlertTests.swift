//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core
import SwiftUI
import XCTest

class ConfirmationAlertTests: XCTestCase {

    func testViewModelProperties() {
        let testee = ConfirmationAlertViewModel(title: "testTitle",
                                                message: "testMessage",
                                                cancelButtonTitle: "testCancel",
                                                confirmButtonTitle: "testConfirm")
        XCTAssertEqual(testee.title, "testTitle")
        XCTAssertEqual(testee.message, "testMessage")
        XCTAssertEqual(testee.cancelButtonTitle, "testCancel")
        XCTAssertEqual(testee.confirmButtonTitle, "testConfirm")
    }

    func testDestructiveConfirmButtonRole() {
        let testee = ConfirmationAlertViewModel(title: "",
                                                message: "",
                                                cancelButtonTitle: "",
                                                confirmButtonTitle: "",
                                                isDestructive: true)
        XCTAssertEqual(testee.confirmButtonRole, .destructive)
    }

    func testNonDestructiveConfirmButtonRole() {
        let testee = ConfirmationAlertViewModel(title: "",
                                                message: "",
                                                cancelButtonTitle: "",
                                                confirmButtonTitle: "",
                                                isDestructive: false)
        XCTAssertNil(testee.confirmButtonRole)
    }

    func testDefaultDestructiveParamBeingNonDestructive() {
        let testee = ConfirmationAlertViewModel(title: "",
                                                message: "",
                                                cancelButtonTitle: "",
                                                confirmButtonTitle: "")
        XCTAssertNil(testee.confirmButtonRole)
    }
}
