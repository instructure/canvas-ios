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

class CalendarDayIconViewTests: CoreTestCase {
    func testCreate() {
        let date = Calendar.current.date(bySetting: .day, value: 28, of: Date())!
        let view = CalendarDayIconView.create(date: date, tintColor: .blue)
        XCTAssertEqual(view.dayLabel.text, "28")
        XCTAssertEqual(view.tintColor, .blue)
    }

    func testSetDate() {
        let date = Calendar.current.date(bySetting: .day, value: 9, of: Date())!
        let view = CalendarDayIconView.create()
        view.setDate(date)
        XCTAssertEqual(view.dayLabel.text, "9")
    }

    func testTintColor() {
        let view = CalendarDayIconView.create()
        view.tintColor = .red
        XCTAssertEqual(view.tintColor, .red)
        XCTAssertEqual(view.dayLabel.textColor, .red)
        XCTAssertEqual(view.iconView.tintColor, .red)
    }
}
