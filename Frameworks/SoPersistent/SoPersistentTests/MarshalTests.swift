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
