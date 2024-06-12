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

@testable import Core
import CoreData
import XCTest
import Combine
import CombineExt

class AddressbookRoleViewModelTests: CoreTestCase {
    private var mockInteractor: AddressbookInteractorMock!
    var testee: AddressbookRoleViewModel!

    private var selected = PassthroughRelay<Recipient>()
    private var selectedRecipients = CurrentValueSubject<[Recipient], Never>([])

    override func setUp() {
        super.setUp()
        mockInteractor = AddressbookInteractorMock(env: AppEnvironment())
        testee = AddressbookRoleViewModel(
            env: environment,
            router: environment.router,
            recipientContext: .init(course: Course.make()),
            interactor: mockInteractor,
            didSelectRecipient: selected,
            selectedRecipients: selectedRecipients
        )
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.recipients.count, 5)
        XCTAssertEqual(testee.roles.count, 5)
        XCTAssertEqual(testee.roleRecipients["Teachers"]?.first?.displayName, "Recipient 1")
        XCTAssertEqual(testee.roleRecipients["Students"]?.first?.displayName, "Recipient 2")
        XCTAssertEqual(testee.roleRecipients["Course Designers"]?.first?.displayName, "Recipient 4")
        XCTAssertEqual(testee.roleRecipients["Teaching Assistants"]?[0].displayName, "Recipient 4")
        XCTAssertEqual(testee.roleRecipients["Teaching Assistants"]?[1].displayName, "Recipient 5")
    }

    func testListFiltering() {
        testee.searchText.value = ""
        XCTAssertEqual(testee.recipients.count, 5)
        testee.searchText.value = "Recipient"
        XCTAssertEqual(testee.recipients.count, 5)
        testee.searchText.value = "Recipient 1"
        XCTAssertEqual(testee.recipients.count, 1)
    }

    func testCancelButton() {
        let sourceView = UIViewController()
        testee.didTapDone.accept(WeakViewController(sourceView))
        XCTAssertNotNil(router.dismissed)
    }

    func testRoleSelection() {
        let sourceView = UIViewController()
        testee.didTapRole.send((roleName: "Students", recipients: testee.recipients, controller: WeakViewController(sourceView)))
        XCTAssertNotNil(router.showExpectation)
    }

    func testRefresh() async {
        XCTAssertFalse(mockInteractor.isRefreshCalled)
        await testee.refresh()
        XCTAssertTrue(mockInteractor.isRefreshCalled)
    }

    func testRolesViewVisible() {
        testee.searchText.value = ""
        XCTAssertTrue(testee.isRolesViewVisible)

        testee.searchText.value = "Test"
        XCTAssertFalse(testee.isRolesViewVisible)
    }

    func testAllRecipientButtonVisible() {
        testee.searchText.value = ""
        XCTAssertTrue(testee.isAllRecipientButtonVisible)

        testee.searchText.value = "Test"
        XCTAssertFalse(testee.isAllRecipientButtonVisible)
    }
}

private class AddressbookInteractorMock: AddressbookInteractor {
    public var state = CurrentValueSubject<StoreState, Never>(.data)
    public var recipients: CurrentValueSubject<[SearchRecipient], Never>
    public private(set) var isRefreshCalled = false

    public init(env: AppEnvironment) {
        self.recipients = CurrentValueSubject<[SearchRecipient], Never>([
            .save(.make(id: "1", name: "Recipient 1", common_courses: ["Course 1": ["TeacherEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "2", name: "Recipient 2", common_courses: ["Course 1": ["StudentEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "3", name: "Recipient 3", common_courses: ["Course 1": ["ObserverEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "4", name: "Recipient 4", common_courses: ["Course 1": ["TaEnrollment", "DesignerEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "5", name: "Recipient 5", common_courses: ["Course 1": ["TaEnrollment"]]), filter: "", in: env.database.viewContext),
        ])
    }

    func refresh() -> Future<Void, Never> {
        isRefreshCalled = true
        return Future<Void, Never> { promise in
            promise(.success(()))
        }
    }
}
