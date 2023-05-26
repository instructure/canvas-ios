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

public extension XCTestCase {

    /**
     This method expects the given publisher to emit an expected single output then finish.
     If the output doesn't match the expectation or there are multiple outputs or the publisher fails the assertion will fail.
     */
    func XCTAssertSingleOutputEquals<Output, Failure>(_ publisher: any Publisher<Output, Failure>,
                                                      _ expectedOutput: Output,
                                                      timeout: TimeInterval = 0.1)
    where Output: Equatable, Failure: Error {
        let outputExpectation = expectation(description: "Output received from publisher")
        outputExpectation.expectedFulfillmentCount = 1
        let finishExpectation = expectation(description: "Publisher finished")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    finishExpectation.fulfill()
                }
            }, receiveValue: { output in
                XCTAssertEqual(output, expectedOutput)
                outputExpectation.fulfill()
            })

        wait(for: [outputExpectation, finishExpectation], timeout: timeout)
        subscription.cancel()
    }

    /**
     This method expects the publisher to finish within the given timeout.
     Useful if you are not directly interested in the result of the publisher.
     If the publisher fails or the timeout is reached the assertion will fail.
     */
    func XCTAssertFinish<Output, Failure>(_ publisher: any Publisher<Output, Failure>,
                                          timeout: TimeInterval = 0.1)
    where Failure: Error {
        let finishExpectation = expectation(description: "Publisher finished")
        finishExpectation.expectedFulfillmentCount = 1

        let subscription = publisher
            .sink { completion in
                if case .finished = completion {
                    finishExpectation.fulfill()
                }
            } receiveValue: { _ in
            }

        wait(for: [finishExpectation], timeout: timeout)
        subscription.cancel()
    }
}
