//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Core
import XCTest

class FutureExtensionsTests: XCTestCase {

    // MARK: - Method: allFinished()

    public func testPublishesUpstreamFinishes() {
        let future1 = Future<Void, Error> { $0(.success(())) }
        let future2 = Future<Void, Error> { $0(.success(())) }
        let futures = [future1, future2]

        let receivedValue = expectation(description: "value received")
        let receivedFinish = expectation(description: "finish received")
        let subscription = futures
            .allFinished()
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        receivedFinish.fulfill()
                    }
                },
                receiveValue: { _ in
                    receivedValue.fulfill()
                })

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    public func testFailsIfOneUpstreamPublisherFails() {
        let future1 = Future<Void, Error> { $0(.success(())) }
        let future2 = Future<Void, Error> { $0(.failure(NSError.internalError())) }
        let futures = [future1, future2]

        let receivedNoValue = expectation(description: "no value received")
        receivedNoValue.isInverted = true
        let receivedError = expectation(description: "error received")
        let subscription = futures
            .allFinished()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError.fulfill()
                        XCTAssertEqual(error as NSError, NSError.internalError())
                    }
                },
                receiveValue: { _ in
                    receivedNoValue.fulfill()
                })

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    public func testWaitsForAllUpstreamFinishes() {
        let future1 = Future<Void, Error> { $0(.success(())) }
        let future2 = Future<Void, Error> { _ in /* Never complete */ }
        let futures = [future1, future2]

        let receivedNoValue = expectation(description: "no value received")
        receivedNoValue.isInverted = true
        let receivedNoCompletion = expectation(description: "no completion received")
        receivedNoCompletion.isInverted = true
        let subscription = futures
            .allFinished()
            .sink(
                receiveCompletion: { _ in
                    receivedNoCompletion.fulfill()
                },
                receiveValue: { _ in
                    receivedNoValue.fulfill()
                })

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}
