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

final class EditCustomFrequencyViewModelTests: CoreTestCase {

    private enum TestConstants {
        static let now = Date.make(year: 2024, month: 1, day: 1, hour: 14, minute: 7)
        static let eventDate = Date.make(year: 2024, month: 3, day: 1, hour: 14, minute: 0)
    }

    private var completionValue: RecurrenceRule?

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.now)
        completionValue = nil
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testInitialValues() {


        

    }

    // MARK: - Helpers

    private func makeViewModel(_ eventDate: Date) -> EditCustomFrequencyViewModel {
        makeViewModel(eventDate, selected: nil)
    }

    private func makeViewModel(_ eventDate: Date, selected: RecurrenceRule?) -> EditCustomFrequencyViewModel {
        return EditCustomFrequencyViewModel(
            rule: selected,
            proposedDate: eventDate,
            completion: { [weak self] newRule in
                self?.completionValue = newRule
            }
        )
    }
}
