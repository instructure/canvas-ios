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

import BackgroundTasks
import Core
import XCTest

class BackgroundProcessingInteractorTests: XCTestCase {
    private var mockScheduler: MockScheduler!
    private var testee: BackgroundProcessingInteractor!

    override func setUp() {
        super.setUp()
        mockScheduler = MockScheduler()
        testee = BackgroundProcessingInteractor(scheduler: mockScheduler)
    }

    override func tearDown() {
        BackgroundProcessingAssembly.resetRegisteredTaskIDs()
        super.tearDown()
    }

    func testForwardsCancelledTaskIDToScheduler() {
        testee.cancel(taskID: "cancelledTaskID")
        XCTAssertEqual(mockScheduler.canceledIdentifier, "cancelledTaskID")
    }

    func testForwardsTaskToSchedulerAndHandlesException() {
        mockScheduler.mockSubmitError = NSError.instructureError("submit error")
        let mockTaskRequest = BGAppRefreshTaskRequest(identifier: "mock")

        testee.schedule(task: mockTaskRequest)

        XCTAssertEqual(mockScheduler.submittedRequest, mockTaskRequest)
    }

    func testHandlesTaskRegistrationError() {
        mockScheduler.mockRegisterResult = false

        XCTAssertNoThrow(testee.register(taskID: "test"))
    }

    func testForwardsRegistrationToScheduler() {
        testee.register(taskID: "test")

        XCTAssertNil(mockScheduler.registeredQueue)
        XCTAssertEqual(mockScheduler.registeredIdentifier, "test")
        XCTAssertNotNil(mockScheduler.registeredLaunchHandler)
    }

    func testMarksBGTaskCompletedWhenTaskIDNotRegistered() {
        testee.register(taskID: "test")
        guard let launchHandler = mockScheduler.registeredLaunchHandler else {
            return XCTFail()
        }
        let mockBGTask = MockBGTask()

        // WHEN
        launchHandler(mockBGTask)

        // THEN
        XCTAssertEqual(mockBGTask.taskCompletionResult, true)
    }

    func testMarksBGTaskCompletedWhenTaskCompletes() {
        let mockBackgroundTask = MockBackgroundTask()
        BackgroundProcessingAssembly.register(taskID: "test") {
            mockBackgroundTask
        }
        testee.register(taskID: "test")
        guard let launchHandler = mockScheduler.registeredLaunchHandler else {
            return XCTFail()
        }
        let mockBGTask = MockBGTask()
        launchHandler(mockBGTask)

        // WHEN
        mockBackgroundTask.complete()

        // THEN
        XCTAssertEqual(mockBGTask.taskCompletionResult, true)
    }

    func testCancelsTaskAndMarksBGTaskCompletedUponBGTaskExpiration() {
        let mockBackgroundTask = MockBackgroundTask()
        BackgroundProcessingAssembly.register(taskID: "test") {
            mockBackgroundTask
        }
        testee.register(taskID: "test")
        guard let launchHandler = mockScheduler.registeredLaunchHandler else {
            return XCTFail()
        }
        let mockBGTask = MockBGTask()
        launchHandler(mockBGTask)

        // WHEN
        mockBGTask.expirationHandler?()

        // THEN
        XCTAssertTrue(mockBackgroundTask.isCancelCalled)
        XCTAssertEqual(mockBGTask.taskCompletionResult, false)
    }
}

private class MockBGTask: CoreBGTask {
    var identifier = "test"
    var expirationHandler: (() -> Void)?

    public private(set) var taskCompletionResult: Bool?

    func setTaskCompleted(success: Bool) {
        taskCompletionResult = success
    }
}

private class MockBackgroundTask: BackgroundTask {
    public private(set) var isCancelCalled = false
    private var completionCallback: (() -> Void)!

    func complete() {
        completionCallback()
    }

    func start(completion: @escaping () -> Void) {
        completionCallback = completion
    }

    func cancel() {
        isCancelCalled = true
    }
}

private class MockScheduler: CoreBGTaskScheduler {
    public var mockRegisterResult = true
    public var mockSubmitError: Error?
    public private(set) var canceledIdentifier: String?
    public private(set) var registeredIdentifier: String?
    public private(set) var registeredQueue: DispatchQueue?
    public private(set) var registeredLaunchHandler: ((CoreBGTask) -> Void)?
    public private(set) var submittedRequest: BGTaskRequest?

    func register(forTaskWithIdentifier identifier: String,
                  using queue: DispatchQueue?,
                  launchHandler: @escaping (CoreBGTask) -> Void) -> Bool {
        registeredIdentifier = identifier
        registeredQueue = queue
        registeredLaunchHandler = launchHandler
        return mockRegisterResult
    }

    func submit(_ request: BGTaskRequest) throws {
        submittedRequest = request

        if let mockSubmitError {
            throw mockSubmitError
        }
    }

    func cancel(taskRequestWithIdentifier identifier: String) {
        canceledIdentifier = identifier
    }
}
