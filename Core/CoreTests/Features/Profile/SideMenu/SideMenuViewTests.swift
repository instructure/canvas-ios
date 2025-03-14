//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI
import Combine
@testable import Core
import TestsFoundation
import XCTest

class SideMenuViewTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        api.mock(GetAccountHelpLinks(for: .student), value: nil)
        api.mock(GetContextPermissions(context: .account("self"), permissions: [.becomeUser]), value: .make(become_user: true))
        api.mock(GetGlobalNavExternalToolsPlacements(enrollment: .student), value: [])
        api.mock(GetUserSettings(userID: "self"), value: .make())
        api.mock(GetUserProfile(userID: "self"), value: .make(
            name: "Eve",
            primary_email: "automated-test-Eve@instructure.com",
            avatar_url: URL(string: "https://localhost/avatar.png")!,
            pronouns: nil
        ))

        api.mock(GetUserRequest(userID: "self"), value: .make())
        api.mock(PutUserSettingsRequest(), value: .make(hide_dashcard_color_overlays: true))
    }

    func testParentItems() {
        let tree = controller(.observer).testTree
        XCTAssertNotNil(tree?.find(id: "Profile.inboxButton"))
        XCTAssertNil(tree?.find(id: "Profile.filesButton"))
        XCTAssertNil(tree?.find(id: "Profile.settingsButton"))
        XCTAssertNil(tree?.find(id: "Profile.showGradesToggle"))
        XCTAssertNil(tree?.find(id: "Profile.colorOverlayToggle"))
        XCTAssertNotNil(tree?.find(id: "Profile.manageChildrenButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.changeUserButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.logOutButton"))
    }

    func testStudentItems() {
        let tree = controller(.student).testTree
        XCTAssertNil(tree?.find(id: "Profile.inboxButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.filesButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.settingsButton"))
        XCTAssertNil(tree?.find(id: "Profile.manageChildrenButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.changeUserButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.logOutButton"))
    }

    func testTeacherItems() {
        let tree = controller(.teacher).testTree
        XCTAssertNil(tree?.find(id: "Profile.inboxButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.filesButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.settingsButton"))
        XCTAssertNil(tree?.find(id: "Profile.showGradesToggle"))
        XCTAssertNil(tree?.find(id: "Profile.manageChildrenButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.changeUserButton"))
        XCTAssertNotNil(tree?.find(id: "Profile.logOutButton"))
    }

    func controller(_ enrollment: HelpLinkEnrollment) -> CoreHostingController<SideMenuView> {
        return hostSwiftUIController(SideMenuView(enrollment))
    }
}
