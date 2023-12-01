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

import Combine
@testable import Core
import XCTest

class AddressbookInteractorLiveTests: CoreTestCase {
    private var testee: AddressbookInteractorLive!
    private var context = RecipientContext(course: Course.make())

    override func setUp() {
        super.setUp()
        mockData()

        testee = AddressbookInteractorLive(env: environment, recipientContext: context)

        waitForState(.data)
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.recipients.value.count, 2)
        XCTAssertEqual(testee.recipients.value.first?.name, "Recipient 1")
    }

    private func mockData() {
        let recipient1 = APISearchRecipient.make(
            id: "1",
            name: "Recipient 1"
        )
        let recipient2 = APISearchRecipient.make(
            id: "2",
            name: "Recipient 2"
        )
        let recipients = [recipient1, recipient2]

        api.mock(GetSearchRecipients(context: context.context), value: recipients)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        let subscription = testee
            .state
            .sink {
                if $0 == state {
                    stateUpdate.fulfill()
                }
            }
        wait(for: [stateUpdate], timeout: 1)
        subscription.cancel()
    }
}
