//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import SwiftUI
import XCTest

class DashboardInvitationViewModelTests: XCTestCase {

    func testInitialState() {
        let testee = DashboardInvitationViewModel(name: "invitation name", courseId: "courseId", enrollmentId: "enrollmentId")
        XCTAssertEqual(testee.state, .active)
        XCTAssertEqual(testee.id, "enrollmentId")
        XCTAssertEqual(testee.name, "invitation name")
        XCTAssertEqual(testee.stateText, Text("You have been invited", bundle: .core))
    }

    func testAccept() {
        let testee = DashboardInvitationViewModel(name: "invitation name", courseId: "courseId", enrollmentId: "enrollmentId")
        testee.accept()
        XCTAssertEqual(testee.state, .accepted)
        XCTAssertEqual(testee.stateText, Text("Invite accepted!", bundle: .core))
    }

    func testDecline() {
        let testee = DashboardInvitationViewModel(name: "invitation name", courseId: "courseId", enrollmentId: "enrollmentId")
        testee.decline()
        XCTAssertEqual(testee.state, .declined)
        XCTAssertEqual(testee.stateText, Text("Invite declined!", bundle: .core))
    }

    func testDismissCallback() {
        let dismissExpectation = expectation(description: "dismiss callback invoked")
        let testee = DashboardInvitationViewModel(name: "invitation name", courseId: "courseId", enrollmentId: "enrollmentId") { model in
            XCTAssertEqual(model.name, "invitation name")
            XCTAssertEqual(model.id, "enrollmentId")
            XCTAssertEqual(model.state, .accepted)
            dismissExpectation.fulfill()
        }
        testee.accept()
        waitForExpectations(timeout: 2)
    }
}
