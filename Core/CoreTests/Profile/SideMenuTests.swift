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

class SideMenuTests: CoreTestCase, LoginDelegate {

    lazy var controller: CoreHostingController<SideMenu> = {
        return hostSwiftUIController(SideMenu(.student))
    }()
    
    var notificationPayload: [AnyHashable: Any]?
    func reduxActionCalled(notification: Notification) {
        notificationPayload = notification.userInfo
    }

    var defaultsDidChange = false
    func userDefaultsDidChange(notification: Notification) {
        defaultsDidChange = true
    }

    var externalURL: URL?
    func openExternalURL(_ url: URL) {
        externalURL = url
    }

    func userDidLogin(session: LoginSession) {}

    var didLogout = false
    func userDidLogout(session: LoginSession) {
         didLogout = true
    }

    var didChangeUser = false
    func changeUser() {
        didChangeUser = true
    }
    
    override func setUp() {
        super.setUp()
        api.mock(GetAccountHelpLinks(for: .student), value: nil)
        api.mock(GetContextPermissions(context: .account("self"), permissions: [.becomeUser]), value: .make(become_user: true))
        api.mock(GetGlobalNavExternalPlacements(), value: [])
        api.mock(GetUserSettings(userID: "self"), value: .make())
        api.mock(GetUserProfile(userID: "self"), value: .make(
            name: "Eve",
            primary_email: "automated-test-Eve@instructure.com",
            avatar_url: URL(string: "https://localhost/avatar.png")!,
            pronouns: nil
        ))
        
        api.mock(GetUserRequest(userID: "self"), value: .make())
        api.mock(PutUserSettingsRequest(), value: .make(hide_dashcard_color_overlays: true))

        let n = NSNotification.Name("redux-action")
        NotificationCenter.default.addObserver(self, selector: #selector(reduxActionCalled(notification:)), name: n, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func testTree() {
        let tree = controller.testTree
        
    }

}
