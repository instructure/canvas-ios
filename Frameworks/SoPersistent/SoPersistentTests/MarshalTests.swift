//
//  MarshalTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoAutomated
import Marshal

class MarshalTests: XCTestCase {
    func testDescribeNSNumber() {
        describe("NSNumber.value:") {
            it("converts Any to NSNumber") {
                // Given
                let num: Any = NSNumber(double: 2.0)

                // When
                let value = try! NSNumber.value(num)

                // Then
                XCTAssertEqual(2.0, value.doubleValue)
            }

            context("when object passed in is not an NSNumber") {
                it("throws an error") {
                    // Given
                    let string: Any = "Foo"
                    var theError: ErrorType?

                    // When
                    do {
                        try NSNumber.value(string)
                        XCTFail()
                    } catch {
                        theError = error
                    }

                    // Then
                    XCTAssertNotNil(theError)
                    if case let Marshal.Error.TypeMismatch(expected: expected, actual: actual) = theError! {
                        XCTAssert(expected is NSNumber.Type)
                        XCTAssert(actual is String.Type)
                    } else {
                        XCTFail("Expected a .TypeMismatch got \(theError)")
                    }
                }
            }
        }
    }
}
