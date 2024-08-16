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

class ParentConversationListViewControllerTests: ParentTestCase {

    private enum TestConstants {
        static let date2018 = DateComponents(calendar: .current, year: 2018, month: 12, day: 25).date!
        static let date2019 = DateComponents(calendar: .current, year: 2019, month: 12, day: 25).date!
    }

    lazy var controller = ParentConversationListViewController.create()

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.date2019)
        api.mock(controller.conversations, value: [
            .make(),
            .make(id: "2", subject: "", workflow_state: .read, last_message: "last", last_message_at: TestConstants.date2018, context_name: "CTX")
        ])
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func loadView() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
    }

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        loadView()
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertFalse(navigation.isNavigationBarHidden)
        XCTAssertEqual(navigation.navigationBar.barStyle, .default)

        XCTAssertTrue(controller.emptyView.isHidden)
        XCTAssertTrue(controller.errorView.isHidden)

        let first = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConversationListCell
        XCTAssertEqual(first?.dateLabel.text, TestConstants.date2019.relativeDateTimeString)
        XCTAssertEqual(first?.contextLabel.text, "Canvas 101")
        XCTAssertEqual(first?.subjectLabel.text, "Subject One")
        XCTAssertEqual(first?.unreadView.isHidden, false)
        XCTAssertEqual(first?.accessibilityLabel, "Subject One, in Canvas 101, the last message was on " + TestConstants.date2019.dateTimeString + " Last Message One, unread")

        let last = controller.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ConversationListCell
        XCTAssertEqual(last?.unreadView.isHidden, true)
        XCTAssertEqual(last?.accessibilityLabel, "(No subject), in CTX, the last message was on " + TestConstants.date2018.dateTimeString + " last")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo("/conversations/1"))
    }

    func testTappingComposeRoutesToCourseActionSheet() {
        loadView()
        controller.composeButton.sendActions(for: .primaryActionTriggered)
        XCTAssertNotNil(router.presented as? ConversationCoursesActionSheet)
    }

    func testRouteToCompose() {
        loadView()
        let course = Course.make()
        let user = User.make()
        controller.courseSelected(course: course, user: user)
        let compose = router.presented as? ComposeViewController
        XCTAssertEqual(compose?.context.id, course.id)
        XCTAssertEqual(compose?.observeeID, user.id)
        XCTAssertEqual(compose?.subjectField.text, course.name)
        XCTAssertEqual(compose?.hiddenMessage, "Regarding: \(user.name)")
    }

    func testErrorEmpty() {
        api.mock(controller.conversations, error: NSError.instructureError("Doh!"))
        loadView()

        XCTAssertTrue(controller.emptyView.isHidden)
        XCTAssertFalse(controller.errorView.isHidden)
        XCTAssertEqual(controller.errorLabel.text, "Doh!")

        api.mock(controller.conversations, value: [])
        controller.retryButton.sendActions(for: .primaryActionTriggered)
    }
}
