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
import CombineExt
import Core
import XCTest

class PublisherExtensionsTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testBindProgressReportsLoadingStateOnSubscription() {
        // MARK: - GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        let loadingStateReceiver = PassthroughRelay<Bool>()
        let valueExpectation = expectation(description: "Progress status received")
        var receivedProgress: Bool?
        loadingStateReceiver
            .sink { isLoading in
                valueExpectation.fulfill()
                receivedProgress = isLoading
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        publisher
            .bindProgress(loadingStateReceiver)
            .sink()
            .store(in: &subscriptions)

        // MARK: - GIVEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedProgress, true)
    }

    func testBindProgressReportsLoadingFinishOnStreamCompletion() {
        // MARK: - GIVEN
        let publisher = PassthroughSubject<Void, Never>()
        let loadingStateReceiver = PassthroughRelay<Bool>()
        let valueExpectation = expectation(description: "Progress status received")
        var receivedProgress: Bool?
        loadingStateReceiver
            .dropFirst() // ignore loading state
            .sink { isLoading in
                valueExpectation.fulfill()
                receivedProgress = isLoading
            }
            .store(in: &subscriptions)
        publisher
            .bindProgress(loadingStateReceiver)
            .sink()
            .store(in: &subscriptions)

        // MARK: - WHEN
        publisher.send(completion: .finished)

        // MARK: - GIVEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedProgress, false)
    }
}
