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

@testable import Core
import XCTest

class TodoVisibilityOptionTests: XCTestCase {

    func testTitles() {
        XCTAssertEqual(TodoVisibilityOption.showPersonalTodos.title, "Show Personal To-dos")
        XCTAssertEqual(TodoVisibilityOption.showCalendarEvents.title, "Show Calendar Events")
        XCTAssertEqual(TodoVisibilityOption.showCompleted.title, "Show Completed")
        XCTAssertEqual(TodoVisibilityOption.favouriteCoursesOnly.title, "Favorite Courses Only")
    }

    func testToOptionItem() {
        let option = TodoVisibilityOption.showPersonalTodos
        let optionItem = option.toOptionItem()

        XCTAssertEqual(optionItem.id, "showPersonalTodos")
        XCTAssertEqual(optionItem.title, "Show Personal To-dos")
    }

    func testAllOptionItems() {
        let optionItems = TodoVisibilityOption.allOptionItems

        XCTAssertEqual(optionItems.count, 4)
        XCTAssertEqual(optionItems[0].id, "showPersonalTodos")
        XCTAssertEqual(optionItems[1].id, "showCalendarEvents")
        XCTAssertEqual(optionItems[2].id, "showCompleted")
        XCTAssertEqual(optionItems[3].id, "favouriteCoursesOnly")
    }
}
