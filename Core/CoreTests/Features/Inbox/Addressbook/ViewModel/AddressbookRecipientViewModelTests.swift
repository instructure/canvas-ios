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

class AddressbookRecipientViewModelTests: CoreTestCase {

    private var testee: AddressbookRecipientViewModel!
    private var recipients: [SearchRecipient] = []

    override func setUp() {
        super.setUp()
        recipients = [
            .save(.make(id: "1", name: "Recipient 1", common_courses: ["Course 1": ["TeacherEnrollment"]]), filter: "", in: environment.database.viewContext),
            .save(.make(id: "2", name: "Recipient 2", common_courses: ["Course 1": ["StudentEnrollment"]]), filter: "", in: environment.database.viewContext),
            .save(.make(id: "3", name: "Recipient 3", common_courses: ["Course 1": ["ObserverEnrollment"]]), filter: "", in: environment.database.viewContext)
        ]
        testee = makeViewModel(canSelectAllRecipient: true)
    }

    func testInitState() {
        XCTAssertEqual(testee.recipients.count, 3)
        XCTAssertEqual(testee.roleName, "Students")
    }

    func testListFiltering() {
        testee.searchText.value = ""
        XCTAssertEqual(testee.recipients.count, 3)
        testee.searchText.value = "Recipient"
        XCTAssertEqual(testee.recipients.count, 3)
        testee.searchText.value = "Recipient 1"
        XCTAssertEqual(testee.recipients.count, 1)
        XCTAssertEqual(testee.recipients.first?.displayName, "Recipient 1")
        XCTAssertEqual(testee.recipients.first?.ids, ["1"])
        XCTAssertNil(testee.recipients.first?.avatarURL)
    }

    func test_listCount_whenCanSelectAllRecipients() {
        XCTAssertEqual(testee.listCount, 4)
    }

    func test_listCount_whenCanNotSelectAllRecipients() {
        testee = makeViewModel(canSelectAllRecipient: false)
        XCTAssertEqual(testee.listCount, 3)
    }

    private func makeViewModel(canSelectAllRecipient: Bool) -> AddressbookRecipientViewModel {
        .init(
            router: environment.router,
            roleName: "Students",
            recipients: recipients.map { Recipient(searchRecipient: $0) },
            canSelectAllRecipient: canSelectAllRecipient,
            recipientDidSelect: .init(),
            selectedRecipients: .init([])
        )
    }
}
