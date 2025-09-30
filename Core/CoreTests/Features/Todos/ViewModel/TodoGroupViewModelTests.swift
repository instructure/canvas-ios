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
import TestsFoundation
import XCTest

class TodoGroupViewModelTests: CoreTestCase {

    func testAccessibilityLabel() {
        let dateComponents = DateComponents(year: 2021, month: 8, day: 7, hour: 12)
        let date = Calendar.current.date(from: dateComponents)!
        let items = [TodoItemViewModel.make(id: "1"), TodoItemViewModel.make(id: "2")]
        
        let group = TodoGroupViewModel(date: date, items: items)
        
        XCTAssertTrue(group.accessibilityLabel.contains("Saturday"))
        XCTAssertTrue(group.accessibilityLabel.contains("August 7"))
        XCTAssertTrue(group.accessibilityLabel.contains("2 items"))
    }
}