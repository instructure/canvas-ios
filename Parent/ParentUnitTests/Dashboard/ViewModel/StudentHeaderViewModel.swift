//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import CombineSchedulers
@testable import Parent
import TestsFoundation
import XCTest

class StudentHeaderViewModelTests: ParentTestCase {
    private var viewModel: StudentHeaderViewModel!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    override func setUp() {
        super.setUp()
        viewModel = StudentHeaderViewModel(
            router: router,
            mainScheduler: testScheduler.eraseToAnyScheduler()
        )
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_didTapStudentView_togglesDropdownState() {
        // WHEN
        viewModel.didTapStudentView.send()

        // THEN
        XCTAssertFalse(viewModel.isDropdownClosed)
        XCTAssertEqual(viewModel.accessibilityValue, "Expanded")

        // WHEN
        viewModel.didTapStudentView.send()

        // THEN
        XCTAssertTrue(viewModel.isDropdownClosed)
        XCTAssertEqual(viewModel.accessibilityValue, "Collapsed")
    }

    func test_didSelectStudent_updatesProperties() {
        let student = User.save(.make(
            name: "Test Student",
            avatar_url: URL(string: "/avatar.inst")!
        ), in: databaseClient)

        // WHEN
        viewModel.didSelectStudent.send(student)

        // THEN
        XCTAssertEqual(
            viewModel.state,
           .student(name: "Test Student", avatarURL: student.avatarURL)
        )
        XCTAssertEqual(
            viewModel.backgroundColor,
            ColorScheme.observee(student.id).color.asColor
        )
        XCTAssertTrue(viewModel.isDropdownClosed)
        XCTAssertEqual(
            viewModel.accessibilityLabel,
            "Current student: Test Student")
        XCTAssertEqual(viewModel.accessibilityHint, "Tap to switch students")
    }

    func test_didSelectStudent_withNil_showsAddStudentState() {
        // WHEN
        viewModel.didSelectStudent.send(nil)

        // THEN
        XCTAssertEqual(viewModel.state, .addStudent)
        XCTAssertEqual(
            viewModel.backgroundColor,
            ColorScheme.observeeBlue.color.asColor
        )
        XCTAssertEqual(
            viewModel.accessibilityLabel,
            String(localized: "Add Student", bundle: .parent)
        )
        XCTAssertEqual(viewModel.accessibilityHint, "")
    }

    func test_updatesBadgeCount() {
        // WHEN
        viewModel.didUpdateBadgeCount.send(5)
        testScheduler.run()

        // THEN
        XCTAssertEqual(viewModel.badgeCount, 5)
        XCTAssertEqual(viewModel.menuAccessibilityHint, String.localizedStringWithFormat(String(localized: "conversation_unread_messages", bundle: .core), 5))

        // WHEN
        viewModel.didUpdateBadgeCount.send(0)
        testScheduler.run()

        // THEN
        XCTAssertEqual(viewModel.badgeCount, 0)
        XCTAssertEqual(viewModel.menuAccessibilityHint, "")
    }

    func test_routesToProfile() {
        viewModel = StudentHeaderViewModel(router: router)
        let vc = UIViewController()

        // WHEN
        viewModel.didTapMenuButton.send(vc)

        // THEN
        XCTAssertTrue(router.lastRoutedTo("/profile", withOptions: .modal()))
    }
}
