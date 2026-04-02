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

import Core
import Combine
import XCTest

class StoreStateMergeTests: XCTestCase {

    func testPublishesWhenStatesAvailable() {
        let s1 = PassthroughSubject<StoreState, Never>()
        let s2 = PassthroughSubject<StoreState, Never>()
        let s3 = PassthroughSubject<StoreState, Never>()
        var output: StoreState?
        let subscription = StoreState
            .combineLatest(s1, s2, s3)
            .sink { output = $0 }

        s1.send(.loading)
        XCTAssertNil(output)
        s2.send(.loading)
        XCTAssertNil(output)
        s3.send(.loading)
        XCTAssertEqual(output, .loading)
        subscription.cancel()
    }

    func testDataOutput() {
        validate([.data, .data, .data], expected: .data)
        validate([.empty, .data, .data], expected: .data)
        validate([.data, .empty, .data], expected: .data)
        validate([.data, .data, .empty], expected: .data)
        validate([.data, .empty, .empty], expected: .data)
        validate([.empty, .empty, .data], expected: .data)
    }

    func testEmptyOutput() {
        validate([.empty, .empty, .empty], expected: .empty)
    }

    func testErrorOutput() {
        validate([.error, .data, .data], expected: .error)
        validate([.data, .error, .data], expected: .error)
        validate([.data, .data, .error], expected: .error)
    }

    func testLoadingOutput() {
        validate([.loading, .data, .data], expected: .loading)
        validate([.data, .loading, .data], expected: .loading)
        validate([.data, .data, .loading], expected: .loading)
    }

    private func validate(_ input: [StoreState], expected: StoreState) {
        let s1 = PassthroughSubject<StoreState, Never>()
        let s2 = PassthroughSubject<StoreState, Never>()
        let s3 = PassthroughSubject<StoreState, Never>()
        var output: StoreState?
        let subscription = StoreState
            .combineLatest(s1, s2, s3)
            .sink { output = $0 }

        s1.send(input[0])
        s2.send(input[1])
        s3.send(input[2])

        XCTAssertEqual(output, expected)
        subscription.cancel()
    }
}
