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

public func XCTAssertVisible(
    _ element: XCUIElement,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertTrue(element.isVisible, "Element is not visible: \(element.debugDescription)", file: file, line: line)
}

public func XCTAssertNotVisible(
    _ element: XCUIElement,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertFalse(element.isVisible, "Element is visible: \(element.debugDescription)", file: file, line: line)
}

public func XCTAssertSelected(
    _ element: XCUIElement,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let errorMessage = "Element is not selected: \(element.debugDescription)"
    if element.elementType == .switch {
        XCTAssertTrue(element.isSwitchSelected, errorMessage, file: file, line: line)
    } else {
        XCTAssertTrue(element.isSelected, errorMessage, file: file, line: line)
    }
}

public func XCTAssertNotSelected(
    _ element: XCUIElement,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let errorMessage = "Element is selected: \(element.debugDescription)"
    if element.elementType == .switch {
        XCTAssertFalse(element.isSwitchSelected, errorMessage, file: file, line: line)
    } else {
        XCTAssertFalse(element.isSelected, errorMessage, file: file, line: line)
    }
}
