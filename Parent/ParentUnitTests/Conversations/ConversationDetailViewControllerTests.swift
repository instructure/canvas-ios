//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class ConversationDetailViewControllerTests: ParentTestCase {
    lazy var controller = ConversationDetailViewController.create(conversationID: "1")

    override func setUp() {
        super.setUp()
        Clock.mockNow(DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 12, day: 25).date!)

        let message = APIConversationMessage.make(id: "1",
                                                  created_at: Clock.now.addDays(-1),
                                                  body: "hello world",
                                                  author_id: "1",
                                                  participating_user_ids: ["1", "2"])
        let c = APIConversation.make(participants: [.make(id: "1", name: "user 1"), .make(id: "2", name: "user 2")], messages: [ message, ])
        api.mock(controller.conversations, value: c)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testRender() {
        controller.view.layoutIfNeeded()
        controller.viewDidLoad()
        controller.viewWillAppear(false)
        let first = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConversationDetailCell
        XCTAssertEqual(first?.fromLabel.text, "user 1")
        XCTAssertEqual(first?.toLabel.text, "to user 2")
        XCTAssertEqual(first?.messageLabel.text, "hello world")
        XCTAssertEqual(first?.dateLabel.text, DateFormatter.localizedString(from: Clock.now.addDays(-1), dateStyle: .medium, timeStyle: .short))
    }
}
