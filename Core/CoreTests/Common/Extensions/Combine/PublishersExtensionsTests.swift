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

import XCTest
import Combine
@testable import Core

class PublishersExtensionsTests: XCTestCase {

    private var subscriptions: Set<AnyCancellable> = []

    func testNoInstanceFailure() {
        let expectation = self.expectation(description: "NoInstanceFailure emits an error")

        Publishers
            .noInstanceFailure(output: String.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual((error as NSError).localizedDescription, "No Instance!")
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive a value")
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTypedFailure() {
        let expectation = self.expectation(description: "TypedFailure emits an error")

        Publishers
            .typedFailure(output: String.self, message: "Custom Error")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual((error as NSError).localizedDescription, "Custom Error")
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive a value")
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTypedEmpty() {
        let expectation = self.expectation(description: "TypedEmpty completes without emitting values")
        Publishers
            .typedEmpty(outputType: String.self, failureType: Error.self)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive a value")
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTypedJustWithValue() {
        let expectation = self.expectation(description: "TypedJust emits a value and completes")
        let randomValue = Double.random(in: 0..<100)

        Publishers
            .typedJust(randomValue, failureType: Error.self)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, randomValue)
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTypedJustWithoutValue() {
        let expectation1 = self.expectation(description: "TypedJust completes")
        let expectation2 = self.expectation(description: "TypedJust emits Void")

        Publishers
            .typedJust(failureType: Error.self)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation1.fulfill()
                }
            }, receiveValue: { _ in
                expectation2.fulfill()
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1, handler: nil)
    }
}
