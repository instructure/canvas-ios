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
import TestsFoundation

class DashboardViewControllerTests: ParentTestCase {
    lazy var vc = Parent.DashboardViewController.create()

    override class func setUp() {
        super.setUp()
    }

    func testLayoutMenu() {
        let students: [APIEnrollment] = [
            .make(observed_user: .make(
                id: "1",
                name: "Full Name",
                short_name: "Short Name",
                pronouns: "Pro/Noun"
            )),
            .make(observed_user: .make(id: "2")),
        ]
        api.mock(GetObservedStudents(observerID: "1"), value: students)
        api.mock(GetContextPermissionsRequest(context: .account("self"), permissions: [.becomeUser]), value: APIPermissions.make())
        api.mock(GetConversationsUnreadCountRequest(), value: .init(unread_count: 3))
        env.userDefaults?.parentCurrentStudentID = nil

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertEqual(vc.avatarView.name, "Full Name")
        XCTAssertEqual(vc.titleLabel.text, "Short Name (Pro/Noun)")
        XCTAssertEqual(vc.dropdownButton.accessibilityLabel, "Current student: Short Name (Pro/Noun). Tap to switch students")
        XCTAssertEqual(vc.studentListStack.arrangedSubviews.count, students.count + 1) // + add button
        XCTAssertEqual(vc.headerView.backgroundColor?.hexString, vc.currentColor.darkenToEnsureContrast(against: .white).hexString)

        XCTAssert(vc.tabsController.viewControllers?[0] is Parent.CourseListViewController)
        XCTAssert(vc.tabsController.viewControllers?[1] is PlannerViewController)
        XCTAssert(vc.tabsController.viewControllers?[2] is ObserverAlertListViewController)

        XCTAssertEqual(vc.profileButton.accessibilityLabel, "Settings")
        XCTAssertEqual(vc.profileButton.accessibilityHint, "3 unread conversations")
        vc.profileButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo("/profile", withOptions: .modal()))

        XCTAssertEqual(vc.studentListHiddenHeight.isActive, true)
        vc.dropdownButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(vc.studentListHiddenHeight.isActive, false)

        (vc.studentListStack.arrangedSubviews[1] as? UIButton)?.sendActions(for: .primaryActionTriggered)
        drainMainQueue() // Wait for animation to complete
        XCTAssertEqual(vc.studentListHiddenHeight.isActive, true)
        XCTAssertEqual(vc.avatarView.name, "Bob")
        XCTAssertEqual(vc.titleLabel.text, "Bob")
        XCTAssertEqual(vc.dropdownButton.accessibilityLabel, "Current student: Bob. Tap to switch students")
        XCTAssertEqual(vc.studentListStack.arrangedSubviews.count, students.count + 1) // + add button

        (vc.studentListStack.arrangedSubviews.last as? UIButton)?.sendActions(for: .primaryActionTriggered)
        let picker = router.presented as! BottomSheetPickerViewController
        XCTAssertEqual(picker.actions.count, 2)
        XCTAssertEqual(picker.actions[0].title, "QR Code")
        XCTAssertEqual(picker.actions[1].title, "Pairing Code")
        picker.actions[0].action()
        XCTAssert(router.presented is ScannerViewController)
        router.dismiss(vc, completion: nil)
        picker.actions[1].action()
        XCTAssert(router.presented is UIAlertController)
        router.dismiss(vc, completion: nil)

        XCTAssertNoThrow(vc.viewWillDisappear(false))
    }

    func testAdmin() {
        env.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin")!)
        api.mock(GetObservedStudents(observerID: "1"), value: [])
        api.mock(GetContextPermissionsRequest(context: .account("self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertEqual(vc.avatarView.isHidden, true)
        XCTAssertEqual(vc.titleLabel.text, "Add Student")
        XCTAssertEqual(vc.dropdownView.isHidden, true)
        XCTAssertEqual(vc.dropdownButton.accessibilityLabel, "Add Student")
        XCTAssertTrue(vc.tabsController.viewControllers?.first is AdminViewController)
    }

    func testShowNotAParentModal() {
        api.mock(GetObservedStudents(observerID: "1"), error: NSError.instructureError("error"))
        api.mock(GetContextPermissionsRequest(context: .account("self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertTrue(router.lastRoutedTo("/wrong-app", withOptions: .modal(isDismissable: false, embedInNav: true)))
    }

    func testShowNotAParentModalNoStudentsToObserve() {
        api.mock(GetObservedStudents(observerID: "1"), value: [])
        api.mock(GetContextPermissionsRequest(context: .account("self"), permissions: [.becomeUser]), value: APIPermissions.make())

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertTrue(router.lastRoutedTo("/wrong-app", withOptions: .modal(isDismissable: false, embedInNav: true)))
    }

    func testPersistedUserIsDefaultSelectedUser() {
        env.userDefaults?.parentCurrentStudentID = "3"

        let students: [APIEnrollment] = [
            .make(observed_user: .make(id: "2")),
            .make(observed_user: .make(id: "3", name: "Full Name", short_name: "User 3")),
            .make(observed_user: .make(id: "4")),
        ]
        api.mock(GetObservedStudents(observerID: "1"), value: students)

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertEqual(vc.titleLabel.text, "User 3")
        XCTAssertEqual(vc.studentListStack.arrangedSubviews.count, students.count + 1)
    }

    func testNoDefaultSelectedUser() {
        env.userDefaults?.parentCurrentStudentID = nil

        let students: [APIEnrollment] = [
            .make(observed_user: .make(id: "2", name: "Full Name", short_name: "User 2")),
            .make(observed_user: .make(id: "3")),
            .make(observed_user: .make(id: "4")),
        ]
        api.mock(GetObservedStudents(observerID: "1"), value: students)

        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertEqual(vc.titleLabel.text, "User 2")
        XCTAssertEqual(vc.studentListStack.arrangedSubviews.count, students.count + 1)
    }
}
