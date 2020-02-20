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

class DashboardViewControllerTests: ParentTestCase {

    var vc: DashboardViewController!

    override func setUp() {
        super.setUp()
        vc = DashboardViewController.create(session: Session.current!)
        vc.loadView()
    }

    func testLayoutMenu() {
        let students: [APIEnrollment] = [
            .make(observed_user: .make(
                id: "1",
                name: "Full Name",
                short_name: "Short Name"
            )),
            .make(observed_user: .make(id: "2")),
        ]
        api.mock(GetObservedStudents(observerID: "1"), value: students)
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertFalse(vc.pageViewController.viewControllers?.first is AdminViewController)
        XCTAssertEqual(vc.navbarNameButton.titleLabel?.text, "Short Name")
        XCTAssertEqual(vc.navbarMenuStackView.arrangedSubviews.count, students.count + 1) // + add button
    }

    func testAdmin() {
        env.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin")!)
        api.mock(GetObservedStudents(observerID: "1"), value: [])
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertTrue( vc.pageViewController.viewControllers?.first is AdminViewController )
    }

    func testShowNotAParentModal() {
        api.mock(GetObservedStudents(observerID: "1"), error: NSError.instructureError("error"))
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertTrue(router.lastRoutedTo(.wrongApp))
    }

    func testShowNotAParentModalNoStudentsToObserve() {
        api.mock(GetObservedStudents(observerID: "1"), value: [])
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertTrue(router.lastRoutedTo(.wrongApp))
    }
}
