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

public func XCTAssertEqualIgnoringCase(
    _ actual: String?,
    _ expected: String?,
    _ messageSuffix: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = actual?.lowercased() == expected?.lowercased()
    let message = "\(actual.testDescription) is not equal ignoring case to \(expected.testDescription)"
    XCTAssert(logic, message + messageSuffix, file: file, line: line)
}

public func XCTAssertContains(
    _ actual: String?,
    _ expectedSubstring: String,
    _ messageSuffix: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = actual?.contains(expectedSubstring) ?? false
    let message = "\(actual.testDescription) does not contain \(expectedSubstring.testDescription)"
    XCTAssert(logic, message + messageSuffix, file: file, line: line)
}

public func XCTAssertContainsIgnoringCase(
    _ actual: String?,
    _ expectedSubstring: String,
    _ messageSuffix: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = actual?.lowercased().contains(expectedSubstring.lowercased()) ?? false
    let message = "\(actual.testDescription) does not contain ignoring case \(expectedSubstring.testDescription)"
    XCTAssert(logic, message + messageSuffix, file: file, line: line)
}

public func XCTAssertHasPrefix(
    _ actual: String?,
    _ expectedPrefix: String,
    _ messageSuffix: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = actual?.hasPrefix(expectedPrefix) ?? false
    let message = "\(actual.testDescription) has no prefix \(expectedPrefix.testDescription)"
    XCTAssert(logic, message + messageSuffix, file: file, line: line)
}

public func XCTAssertHasSuffix(
    _ actual: String?,
    _ expectedSuffix: String,
    _ messageSuffix: String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let logic = actual?.hasSuffix(expectedSuffix) ?? false
    let message = "\(actual.testDescription) has no suffix \(expectedSuffix.testDescription)"
    XCTAssert(logic, message + messageSuffix, file: file, line: line)
}

// MARK: - Helpers

private extension String {
    var testDescription: String {
        "(\"" + self + "\")"
    }
}

private extension String? {
    var testDescription: String {
        (self ?? "nil").testDescription
    }
}
