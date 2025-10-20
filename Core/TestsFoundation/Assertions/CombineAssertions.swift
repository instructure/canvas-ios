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

import Combine
import XCTest

extension XCTestCase {

    // MARK: - Assert Single Output and Finish

    /// Expects `publisher` to emit a single output matching `expectedOutput`, then finish.
    /// If the output doesn't match the expectation or the publisher fails: the assertion will fail.
    /// If there are multiple outputs: it will crash with "multiple calls made to -[XCTestExpectation fulfill]"
    public func XCTAssertSingleOutputEqualsAndFinish<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        _ expectedOutput: Output,
        timeout: TimeInterval = 1,
        _ messageSuffix: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Output: Equatable, Failure: Error {
        let outputExpectation = expectation(description: "Output received from publisher")
        outputExpectation.expectedFulfillmentCount = 1
        let finishExpectation = expectation(description: "Publisher finished")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { completion in
                    if completion.isFinished {
                        finishExpectation.fulfill()
                    }
                },
                receiveValue: { output in
                    XCTAssertEqual(output, expectedOutput, messageSuffix, file: file, line: line)
                    outputExpectation.fulfill()
                }
            )

        wait(for: [outputExpectation, finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    /// Expects `publisher` to emit a single output matching `assertions`, then finish.
    /// If the provided assertion fails on the output or the publisher fails: the assertion will fail.
    /// If there are multiple outputs: it will crash with: "multiple calls made to -[XCTestExpectation fulfill]"
    public func XCTAssertSingleOutputAndFinish<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        timeout: TimeInterval = 1,
        assertions: @escaping (Output) -> Void
    ) where Failure: Error {
        let outputExpectation = expectation(description: "Output received from publisher")
        outputExpectation.expectedFulfillmentCount = 1
        let finishExpectation = expectation(description: "Publisher finished")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { completion in
                    if completion.isFinished {
                        finishExpectation.fulfill()
                    }
                },
                receiveValue: { output in
                    assertions(output)
                    outputExpectation.fulfill()
                }
            )

        wait(for: [outputExpectation, finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    // MARK: - Assert Single Output (ignore completion)

    /// Expects `publisher` to emit a single output matching `expectedOutput`.
    /// It ignores finish or failure events.
    /// If there are multiple outputs: it will crash with: "multiple calls made to -[XCTestExpectation fulfill]"
    public func XCTAssertSingleOutputEquals<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        _ expectedOutput: Output,
        timeout: TimeInterval = 1,
        _ messageSuffix: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Output: Equatable, Failure: Error {
        let outputExpectation = expectation(description: "Output received from publisher")
        outputExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { output in
                    XCTAssertEqual(output, expectedOutput, messageSuffix, file: file, line: line)
                    outputExpectation.fulfill()
                }
            )

        wait(for: [outputExpectation], timeout: timeout)
        subscription.cancel()
    }

    /// Expects `publisher` to emit a single output matching `assertions`.
    /// It ignores finish or failure events.
    /// If there are multiple outputs: it will crash with: "multiple calls made to -[XCTestExpectation fulfill]"
    public func XCTAssertSingleOutput<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        timeout: TimeInterval = 1,
        assertions: @escaping (Output) -> Void
    ) where Failure: Error {
        let outputExpectation = expectation(description: "Output received from publisher")
        outputExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { output in
                    assertions(output)
                    outputExpectation.fulfill()
                }
            )

        wait(for: [outputExpectation], timeout: timeout)
        subscription.cancel()
    }

    // MARK: - Assert First Output (ignore completion & further outputs)

    /// Expects the first output of `publisher` to match `expectedOutput`.
    /// It ignores finish or failure events, and also ignores further outputs.
    public func XCTAssertFirstValueEquals<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        _ expectedOutput: Output,
        timeout: TimeInterval = 1,
        _ messageSuffix: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Output: Equatable, Failure: Error {
        XCTAssertSingleOutputEquals(
            publisher.eraseToAnyPublisher().first(),
            expectedOutput,
            timeout: timeout,
            messageSuffix,
            file: file,
            line: line
        )
    }

    /// Expects the first output of `publisher` to match `assertions`.
    /// It ignores finish or failure events, and also ignores further outputs.
    public func XCTAssertFirstValue<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        timeout: TimeInterval = 1,
        assertions: @escaping (Output) -> Void
    ) where Failure: Error {
        XCTAssertSingleOutput(
            publisher.eraseToAnyPublisher().first(),
            timeout: timeout,
            assertions: assertions
        )
    }

    // MARK: - Assert Finish

    /**
     This method expects the publisher to finish within the given timeout.
     Useful if you are not directly interested in the result of the publisher.
     If the publisher fails or the timeout is reached the assertion will fail.
     */
    public func XCTAssertFinish<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Failure: Error {
        let finishExpectation = expectation(description: "Publisher finished")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { completion in
                    finishExpectation.fulfill()

                    if let error = completion.error {
                        XCTFail("Unexpected failure while waiting on finish event: \(error)", file: file, line: line)
                    }
                },
                receiveValue: { _ in }
            )

        wait(for: [finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    // MARK: - Assert Failure

    public func XCTAssertFailure<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        assertOnOutput: Bool = true,
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Failure: Error {
        let finishExpectation = expectation(description: "Publisher failed")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { completion in
                    finishExpectation.fulfill()

                    if completion.isFinished {
                        XCTFail("Unexpected finish event while waiting on failure.", file: file, line: line)
                    }
                },
                receiveValue: { _ in
                    if assertOnOutput {
                        XCTFail("Received unexpected output from publisher.", file: file, line: line)
                    }
                }
            )

        wait(for: [finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    public func XCTAssertFailureEquals<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        _ expectedError: Failure,
        assertOnOutput: Bool = true,
        timeout: TimeInterval = 1,
        _ messageSuffix: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where Failure: Error, Failure: Equatable {
        let finishExpectation = expectation(description: "Publisher failed")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(
                receiveCompletion: { completion in
                    finishExpectation.fulfill()

                    switch completion {
                    case .finished:
                        XCTFail("Unexpected finish event while waiting on failure.", file: file, line: line)
                    case .failure(let error):
                        XCTAssertEqual(error, expectedError, messageSuffix, file: file, line: line)
                    }
                },
                receiveValue: { _ in
                    if assertOnOutput {
                        XCTFail("Received unexpected output from publisher.", file: file, line: line)
                    }
                }
            )

        wait(for: [finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    // MARK: - Assert No Output

    public func XCTAssertNoOutput<Output, Failure>(
        _ publisher: any Publisher<Output, Failure>,
        timeout: TimeInterval = 1
    ) where Failure: Error {
        let noValueExpectation = expectation(description: "Publisher sent no value.")
        noValueExpectation.isInverted = true

        let subscription = publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    noValueExpectation.fulfill()
                }
            )

        wait(for: [noValueExpectation], timeout: timeout)
        subscription.cancel()
    }
}
