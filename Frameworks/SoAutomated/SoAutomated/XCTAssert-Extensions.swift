//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import ReactiveSwift

// Assert equality between two doubly nested arrays of equatables.
internal func XCTAssertEqual<T: Equatable>(_ expression1: @autoclosure () -> [[T]],
                             _ expression2: @autoclosure () -> [[T]], _ message: String = "",
                             file: StaticString = #file, line: UInt = #line) {

    let lhs = expression1()
    let rhs = expression2()
    XCTAssertEqual(lhs.count, rhs.count, "Expected \(lhs.count) elements, but found \(rhs.count).",
        file: file, line: line)

    zip(lhs, rhs).forEach { xs, ys in
        XCTAssertEqual(xs, ys, "Expected \(lhs), but found \(rhs): \(message)", file: file, line: line)
    }
}

// Assert equality between arrays of optionals of equatables.
internal func XCTAssertEqual <T: ReactiveSwift.OptionalProtocol>
    (_ expression1: [T], _ expression2: [T], _ message: String = "",
     file: StaticString = #file, line: UInt = #line) where T.Wrapped: Equatable {

    XCTAssertEqual(
        expression1.count, expression2.count,
        "Expected \(expression1.count) elements, but found \(expression2.count).",
        file: file, line: line
    )

    zip(expression1, expression2).forEach { xs, ys in
        XCTAssertEqual(
            xs.optional, ys.optional,
            "Expected \(expression1), but found \(expression2): \(message)",
            file: file, line: line
        )
    }
}
