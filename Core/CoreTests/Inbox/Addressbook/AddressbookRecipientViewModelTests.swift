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
    var testee: AddressbookRecipientViewModel!
    private var selected = CurrentValueRelay<[SearchRecipient]>([])

    override func setUp() {
        super.setUp()
        let recipients: [SearchRecipient] = [
            .save(.make(id: "1", name: "Recipient 1", common_courses: ["Course 1": ["TeacherEnrollment"]]), filter: "", in: environment.database.viewContext),
            .save(.make(id: "2", name: "Recipient 2", common_courses: ["Course 1": ["StudentEnrollment"]]), filter: "", in: environment.database.viewContext),
            .save(.make(id: "3", name: "Recipient 3", common_courses: ["Course 1": ["ObserverEnrollment"]]), filter: "", in: environment.database.viewContext),
        ]
        testee = AddressbookRecipientViewModel(router: environment.router, roleName: "Students", recipients: recipients, recipientDidSelect: selected)
    }

    func testInitState() {
        XCTAssertEqual(testee.recipients.count, 3)
        XCTAssertEqual(testee.roleName, "Students")
    }

    func testListFiltering() {
        testee.searchText = ""
        XCTAssertEqual(testee.filteredRecipients().count, 3)
        testee.searchText = "Recipient"
        XCTAssertEqual(testee.filteredRecipients().count, 3)
        testee.searchText = "Recipient 1"
        XCTAssertEqual(testee.filteredRecipients().count, 1)
    }

    func testRecipientSelection() {
        let sourceView = UIViewController()
        testee.recipientDidTap.send((recipient: [testee.recipients.first!], controller: WeakViewController(sourceView)))
        XCTAssertNotNil(router.dismissed)
    }

    func testAllRecipientSelection() {
        let sourceView = UIViewController()
        testee.allRecipientDidTap.send((recipient: [testee.recipients.first!], controller: WeakViewController(sourceView)))
        XCTAssertNotNil(router.dismissed)
    }
}
