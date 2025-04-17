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

<<<<<<<< HEAD:packages/HorizonUI/Sources/HorizonUI/Sources/Foundation/Spaces/HorizonUI.Spaces.Primitivies.swift
public extension HorizonUI.Spaces {
    struct Primitives: Sendable {
        public let space2: CGFloat = 2
        public let space4: CGFloat = 4
        public let space8: CGFloat = 8
        public let space10: CGFloat = 10
        public let space12: CGFloat = 12
        public let space16: CGFloat = 16
        public let space24: CGFloat = 24
        public let space32: CGFloat = 32
        public let space36: CGFloat = 36
        public let space40: CGFloat = 40
        public let space48: CGFloat = 48
========
final class RecurrenceRuleSelectionDescriptionTests: XCTestCase {

    func test_selectionText() {
        XCTAssertEqual(RecurrenceFrequency.daily.selectionText, String(localized: "Daily", bundle: .core))
        XCTAssertEqual(RecurrenceFrequency.weekly.selectionText, String(localized: "Weekly", bundle: .core))
        XCTAssertEqual(RecurrenceFrequency.monthly.selectionText, String(localized: "Monthly", bundle: .core))
        XCTAssertEqual(RecurrenceFrequency.yearly.selectionText, String(localized: "Yearly", bundle: .core))
>>>>>>>> origin/master:Core/CoreTests/Features/Planner/CalendarEvent/Model/Helpers/RecurrenceRule+SelectionDescriptionTests.swift
    }
}
