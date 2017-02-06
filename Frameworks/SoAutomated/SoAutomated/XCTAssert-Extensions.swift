//
//  XCTAssert-Extensions.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 1/12/17.
//  Copyright © 2017 instructure. All rights reserved.
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
