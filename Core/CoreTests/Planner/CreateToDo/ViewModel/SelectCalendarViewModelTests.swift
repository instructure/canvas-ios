//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI
import XCTest

final class SelectCalendarViewModelTests: CoreTestCase {

    private enum TestConstants {
        static let context: Context = .user("123")
        static let calendars: [(name: String, context: Context)] = [
            ("Course 2", .course("2")),
            ("Course 1", .course("1")),
            ("Course 4", .course("4")),
            ("User 42", .user("42")),
            ("User 3", .user("3")),
            ("B Group", .group("0")),
            ("A Group", .group("6")),
        ]
    }

    private var calendarListProviderInteractor: CalendarFilterInteractorPreview!
    private var testee: SelectCalendarViewModel!

    private var inputSelectedContext: Context?

    override func setUp() {
        super.setUp()
        calendarListProviderInteractor = .init()
        XCTAssertFinish(calendarListProviderInteractor.loadFilters(with: TestConstants.calendars))
        testee = makeViewModel()
    }

    override func tearDown() {
        calendarListProviderInteractor = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Selection

    func testIsSelectedGetsInitialValue() {
        inputSelectedContext = TestConstants.context
        testee = makeViewModel()

        XCTAssertEqual(testee.selectedContext, TestConstants.context)
    }

    func testIsSelected() {
        // initial state when binding has no value set behorehand
        XCTAssertEqual(inputSelectedContext, nil)
        XCTAssertEqual(testee.selectedContext, nil)

        testee.isSelected(context: TestConstants.context).wrappedValue = true
        XCTAssertEqual(inputSelectedContext, TestConstants.context)
        XCTAssertEqual(testee.selectedContext, TestConstants.context)

        // false should not deselect
        testee.isSelected(context: TestConstants.calendars[0].context).wrappedValue = false
        XCTAssertEqual(inputSelectedContext, TestConstants.context)
        XCTAssertEqual(testee.selectedContext, TestConstants.context)
    }

    // MARK: - Sections

    func testSectionsShowsOnlyAllowedCalendarTypes() {
        XCTAssertEqual(hasCalendarsOfType(.user), true)
        XCTAssertEqual(hasCalendarsOfType(.course), true)
        XCTAssertEqual(hasCalendarsOfType(.group), true)

        testee = makeViewModel(calendarTypes: [.user, .course])
        XCTAssertEqual(hasCalendarsOfType(.user), true)
        XCTAssertEqual(hasCalendarsOfType(.course), true)
        XCTAssertEqual(hasCalendarsOfType(.group), false)

        testee = makeViewModel(calendarTypes: [.group])
        XCTAssertEqual(hasCalendarsOfType(.user), false)
        XCTAssertEqual(hasCalendarsOfType(.course), false)
        XCTAssertEqual(hasCalendarsOfType(.group), true)
    }

    func testSectionsShowsOnlyFirstUserCalendar() {
        guard testee.sections.count > 0
                && testee.sections[0].items.count > 0
        else {
            XCTFail("Invalid section or item count")
            return
        }

        XCTAssertEqual(testee.sections[0].items[0].name, "User 42")
    }

    func testSectionsOrdersProperly() {
        guard testee.sections.count == 3
                && testee.sections[0].items.count == 1
                && testee.sections[1].items.count == 3
                && testee.sections[2].items.count == 2
        else {
            XCTFail("Invalid section or item count")
            return
        }

        XCTAssertEqual(testee.sections[0].items[0].name, "User 42")

        XCTAssertEqual(testee.sections[1].items[0].name, "Course 1")
        XCTAssertEqual(testee.sections[1].items[1].name, "Course 2")
        XCTAssertEqual(testee.sections[1].items[2].name, "Course 4")

        XCTAssertEqual(testee.sections[2].items[0].name, "A Group")
        XCTAssertEqual(testee.sections[2].items[1].name, "B Group")
    }

    // MARK: - Private helpers

    private func makeViewModel(
        calendarListProviderInteractor: CalendarFilterInteractor? = nil,
        calendarTypes: Set<CalendarType> = [.user, .course, .group],
        selectedContext: Binding<Context?>? = nil
    ) -> SelectCalendarViewModel {
        .init(
            calendarListProviderInteractor: calendarListProviderInteractor ?? self.calendarListProviderInteractor,
            calendarTypes: calendarTypes,
            selectedContext: selectedContext ?? Binding(
                get: { [weak self] in self?.inputSelectedContext },
                set: { [weak self] in self?.inputSelectedContext = $0 }
            )
        )
    }

    private func hasCalendarsOfType(_ type: ContextType) -> Bool {
        testee.sections.contains {
            $0.items.contains { calendar in calendar.context.contextType == type }
        }
    }
}
