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
    private var selected = CurrentValueRelay<[SearchRecipient]>([])

    override func setUp() {
        super.setUp()
        mockInteractor = AddressbookInteractorMock(env: AppEnvironment())
        testee = AddressbookRoleViewModel(router: environment.router, recipientContext: .init(course: Course.make()), interactor: mockInteractor, recipientDidSelect: selected)
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.recipients.count, 3)
        XCTAssertEqual(testee.roles.count, 3)
        XCTAssertEqual(testee.roleRecipients["Teacher"]?.first?.name, "Recipient 1")
        XCTAssertEqual(testee.roleRecipients["Student"]?.first?.name, "Recipient 2")
        XCTAssertEqual(testee.roleRecipients["Observer"]?.first?.name, "Recipient 3")
    }
}

private class AddressbookInteractorMock: AddressbookInteractor {
    public var state = CurrentValueSubject<StoreState, Never>(.data)
    public var recipients: CurrentValueSubject<[SearchRecipient], Never>

    public init(env: AppEnvironment) {
        self.recipients = CurrentValueSubject<[SearchRecipient], Never>([
            .save(.make(id: "1", name: "Recipient 1", common_courses: ["Course 1": ["TeacherEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "2", name: "Recipient 2", common_courses: ["Course 1": ["StudentEnrollment"]]), filter: "", in: env.database.viewContext),
            .save(.make(id: "3", name: "Recipient 3", common_courses: ["Course 1": ["ObserverEnrollment"]]), filter: "", in: env.database.viewContext),
        ])

    }

}
