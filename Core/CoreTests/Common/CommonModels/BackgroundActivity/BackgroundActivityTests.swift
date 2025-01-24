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
import TestsFoundation

class BackgroundActivityTests: XCTestCase {
    let mockProcessManager = MockProcessManager()
    var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        mockProcessManager.expireActivity()
        mockProcessManager.reset()
        super.tearDown()
    }

    func testFutureCompletesWhenBackgroundActivityFailsToStart() {
        // MARK: - GIVEN
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let futureFinished = expectation(description: "Future finished")
        var result: Subscribers.Completion<Never>?
        testee
            .start(abortHandler: {})
            .sink { completion in
                futureFinished.fulfill()
                result = completion
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        mockProcessManager.expireActivity()

        // MARK: - THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(result, .finished)
    }

    func testStartsBackgroundActivity() {
        // MARK: - GIVEN
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let futureFinished = expectation(description: "Future finished")
        var result: Subscribers.Completion<Never>?
        testee
            .start(abortHandler: {})
            .sink { completion in
                result = completion
                futureFinished.fulfill()
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        mockProcessManager.startActivity()

        // MARK: - THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(result, .finished)
        XCTAssertTrue(mockProcessManager.isExecutingBackgroundBlock)
        XCTAssertEqual(mockProcessManager.reason, "test")
    }

    func testBlocksBackgroundBlockUntilItExpires() {
        // MARK: - GIVEN
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let futureFinished = expectation(description: "Future finished")
        testee
            .start(abortHandler: {})
            .sink { _ in
                futureFinished.fulfill()
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        mockProcessManager.startActivity()
        waitForExpectations(timeout: 1)
        waitUntil(shouldFail: true) {
            mockProcessManager.isExecutingBackgroundBlock
        }
        mockProcessManager.expireActivity()

        // MARK: - THEN
        drainMainQueue()
        XCTAssertFalse(mockProcessManager.isExecutingBackgroundBlock)
    }

    func testBlocksBackgroundBlockUntilFinish() {
        // MARK: - GIVEN
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let startFinished = expectation(description: "Future finished")
        testee
            .start(abortHandler: {})
            .sink { _ in
                startFinished.fulfill()
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        mockProcessManager.startActivity()
        drainMainQueue()
        waitForExpectations(timeout: 1)

        waitUntil(shouldFail: true) {
            mockProcessManager.isExecutingBackgroundBlock
        }

        let stopFinished = expectation(description: "Future finished")
        testee
            .stop()
            .sink { _ in
                stopFinished.fulfill()
            }
            .store(in: &subscriptions)

        // MARK: - THEN
        waitForExpectations(timeout: 1)
        drainMainQueue()
        XCTAssertFalse(mockProcessManager.isExecutingBackgroundBlock)
    }

    func testMultipleStartRequestOnlyOneBackgroundSession() {
        // MARK: - GIVEN
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let start1Finished = expectation(description: "Future finished")
        let start2Finished = expectation(description: "Future finished")

        // MARK: - WHEN
        testee
            .start(abortHandler: {})
            .sink { _ in
                start1Finished.fulfill()
            }
            .store(in: &subscriptions)
        mockProcessManager.startActivity()
        wait(for: [start1Finished], timeout: 1)
        testee
            .start(abortHandler: {})
            .sink { _ in
                start2Finished.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [start2Finished], timeout: 1)

        // MARK: - THEN
        XCTAssertEqual(mockProcessManager.backgroundActivityRequestCount, 1)
    }

    func testAbortHandlerCalledWhenSessionIsTerminated() {
        // MARK: - GIVEN
        let abortHandlerInvoked = expectation(description: "Abort handle block called")
        let testee = BackgroundActivity(processManager: mockProcessManager,
                                        activityName: "test")
        let startFinished = expectation(description: "Future finished")
        testee
            .start { abortHandlerInvoked.fulfill() }
            .sink { _ in
                startFinished.fulfill()
            }
            .store(in: &subscriptions)
        mockProcessManager.startActivity()
        wait(for: [startFinished], timeout: 1)

        // MARK: - WHEN
        mockProcessManager.expireActivity()
        wait(for: [abortHandlerInvoked], timeout: 1)
    }
}

class MockProcessManager: ProcessManager {
    private var activityBlock: ((Bool) -> Void)?
    public private(set) var isExecutingBackgroundBlock = false
    public private(set) var backgroundActivityRequestCount = 0
    public private(set) var reason: String?

    func performExpiringActivity(reason: String, completion: @escaping (Bool) -> Void) {
        activityBlock = completion
        backgroundActivityRequestCount += 1
        self.reason = reason
    }

    func reset() {
        activityBlock = nil
        backgroundActivityRequestCount = 0
        reason = nil
    }

    func expireActivity() {
        activityBlock?(true)
    }

    func startActivity() {
        DispatchQueue.global().async { [self] in
            isExecutingBackgroundBlock = true
            activityBlock?(false)
            isExecutingBackgroundBlock = false
        }
    }
}
