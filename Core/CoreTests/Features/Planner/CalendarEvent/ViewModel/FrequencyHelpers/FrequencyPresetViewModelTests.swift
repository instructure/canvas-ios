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

import XCTest
@testable import Core

final class FrequencyPresetViewModelTests: XCTestCase {

    func testTitle() {
        let rule = RecurrenceRule(recurrenceWith: .daily, interval: 1)

        var testee = makeViewModel(preset: .noRepeat)
        XCTAssertEqual(testee.title, String(localized: "Does Not Repeat", bundle: .core))

        testee = makeViewModel(preset: .daily)
        XCTAssertEqual(testee.title, String(localized: "Daily", bundle: .core))

        testee = makeViewModel(preset: .weeklyOnThatDay)
        XCTAssertEqual(testee.title.hasPrefix(String(localized: "Weekly", bundle: .core)), true)

        testee = makeViewModel(preset: .monthlyOnThatWeekday)
        XCTAssertEqual(testee.title.hasPrefix(String(localized: "Monthly", bundle: .core)), true)

        testee = makeViewModel(preset: .yearlyOnThatMonth)
        XCTAssertEqual(testee.title.hasPrefix(String(localized: "Annually", bundle: .core)), true)

        testee = makeViewModel(preset: .everyWeekday)
        XCTAssertEqual(testee.title, String(localized: "Every Weekday (Monday to Friday)", bundle: .core))

        testee = makeViewModel(preset: .custom(rule))
        XCTAssertEqual(testee.title, String(localized: "Custom", bundle: .core))

        testee = makeViewModel(preset: .selected(title: "some title", rule: rule))
        XCTAssertEqual(testee.title, "some title")

        testee = makeViewModel(preset: nil)
        XCTAssertEqual(testee.title, String(localized: "Custom", bundle: .core))
    }

    private func makeViewModel(preset: FrequencyPreset?) -> FrequencyPresetViewModel {
        .init(preset: preset, date: .make(year: 1984, month: 1, day: 1))
    }
}
