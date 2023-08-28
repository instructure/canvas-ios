//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public func waitUntil(
    _ timeout: TimeInterval = 10,
    shouldFail: Bool = false,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: @autoclosure () -> String = "waitUntil timed out",
    predicate: () -> Bool
) {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate() {
        if Date() > deadline {
            if shouldFail {
                XCTFail(failureMessage(), file: (file), line: line)
            }
            break
        }
        RunLoop.current.run(until: Date() + 0.1)
    }
}
