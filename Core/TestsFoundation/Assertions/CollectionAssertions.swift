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

import Foundation
import XCTest

// MARK: - Contains Equatable

public func XCTAssertContains<T: Collection<E>, E: Equatable>(
    _ collection: T?,
    _ expectedElement: T.Element,
    _ message: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = collection?.contains(expectedElement) ?? false
    XCTAssert(logic, message, file: file, line: line)
}

public func XCTAssertNotContains<T: Collection<E>, E: Equatable>(
    _ collection: T,
    _ expectedElement: T.Element,
    _ message: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = !collection.contains(expectedElement)
    XCTAssert(logic, message, file: file, line: line)
}

// MARK: - Contains via closure

public func XCTAssertContains<T: Collection>(
    _ collection: T?,
    _ expectedElement: (T.Element) -> Bool,
    _ message: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = collection?.contains(where: expectedElement) ?? false
    XCTAssert(logic, message, file: file, line: line)
}

public func XCTAssertNotContains<T: Collection>(
    _ collection: T,
    _ expectedElement: (T.Element) -> Bool,
    _ message: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = !collection.contains(where: expectedElement)
    XCTAssert(logic, message, file: file, line: line)
}
