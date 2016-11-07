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
    
    

@testable import TooLegit
import XCTest
import SoAutomated
import Result
import ReactiveCocoa
import SoLazy
import Marshal

class TooLegitTests: XCTestCase {

    func testWrappingAThrowingFunctionInASignalProducer_whenTheFunctionDoesNotThrow_sendsTheValueOfTheFunction() {
        let expectation = expectationWithDescription("value was sent")
        let producer = attemptProducer {
            return try throwError(nil)
        }

        producer.startWithNext { _ in expectation.fulfill() }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWrappingAThrowingFunctionInASignalProducer_whenTheFunctionThrowsAnNSError_catchesAndSendsTheError() {
        let expectation = expectationWithDescription("error was caught and sent")
        let error = NSError(subdomain: "TooLegitTests", description: "test catching NSError")

        attemptProducer {
            return try throwError(error)
        }
        .startWithFailed { error in
            if error.localizedDescription == "test catching NSError" {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWrappingAThrowingFunctionInASignalProducer_whenTheFunctionThrowsAMarshalError_catchesAndSendsTheErrorAsAnNSError() {
        let expectation = expectationWithDescription("marshal error was caught and sent as an NSError")
        let error = Marshal.Error.KeyNotFound(key: "foo")

        attemptProducer {
            return try throwError(error)
        }
        .startWithFailed { error in
            if error.localizedDescription == "There was a problem interpreting a response from the server." {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWrappingABlockInASignalProducer_waitsToInvokeTheBlockUntilTheProducerStarts() {
        var invoked = false
        blockProducer { invoked = true }
        XCTAssertFalse(invoked)
    }

    func testWrappingABlockInASignalProducer_invokesTheBlockWhenTheProducerStarts() {
        let expectation = expectationWithDescription("block was invoked")
        blockProducer {
            return expectation.fulfill()
        }
        .start()
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    private func throwError(error: ErrorType?) throws -> Bool {
        if let error = error {
            throw error
        }
        return true
    }

}
