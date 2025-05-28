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

import XCTest
import TestsFoundation
@testable import Core

final class OptionItemIdentifiableTests: XCTestCase {

    func test_isMatch() {
        let testee = OptionItemIdentifiableMock("42")

        XCTAssertEqual(testee.isMatch(for: OptionItem(id: "42", title: "7")), true)

        XCTAssertEqual(testee.isMatch(for: OptionItem(id: "7", title: "42")), false)
        XCTAssertEqual(testee.isMatch(for: OptionItem(id: "", title: "42")), false)
    }

    func test_optionItemId_whenIdentifiable() {
        let testee = IdentifiableMock(id: "42")

        XCTAssertEqual(testee.optionItemId, "42")
    }

    func test_optionItemId_whenStringRawRepresentable() {
        let testee = StringRawRepresentableMock.someExampleCase

        XCTAssertEqual(testee.optionItemId, "someExampleCase")
    }

    func test_elementForOptionItem() {
        let testee = [
            OptionItemIdentifiableMock("0"),
            OptionItemIdentifiableMock("1"),
            OptionItemIdentifiableMock("2"),
            OptionItemIdentifiableMock("3")
        ]

        XCTAssertEqual(testee.element(for: OptionItem(id: "2", title: "")), testee[2])
        XCTAssertEqual(testee.element(for: OptionItem(id: "42", title: "")), nil)
    }

    func test_optionForItem() {
        let testee = [
            OptionItem(id: "0", title: ""),
            OptionItem(id: "1", title: ""),
            OptionItem(id: "2", title: ""),
            OptionItem(id: "3", title: "")
        ]

        XCTAssertEqual(testee.option(for: OptionItemIdentifiableMock("2")), testee[2])
        XCTAssertEqual(testee.option(for: OptionItemIdentifiableMock("42")), nil)
    }
}

// MARK: - Private helpers

private struct OptionItemIdentifiableMock: OptionItemIdentifiable, Equatable {
    var optionItemId: String = ""

    init(_ optionItemId: String) {
        self.optionItemId = optionItemId
    }
}

private struct IdentifiableMock: Identifiable, OptionItemIdentifiable {
    var id: String = ""
}

private enum StringRawRepresentableMock: String, OptionItemIdentifiable {
    case someExampleCase
}
