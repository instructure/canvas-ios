//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import Combine
import CombineSchedulers
import XCTest

class BulkPublishInteractorTests: CoreTestCase {

    private let bulkPublishRequest = PutBulkPublishModulesRequest(
        courseId: "1",
        moduleIds: ["moduleId1", "moduleId2"],
        action: .publish(.modulesAndItems)
    )

    func testPublishFailsIfInitialRequestFails() {
        api.mock(bulkPublishRequest, error: NSError.internalError(code: 7357))

        // WHEN
        let testee = BulkPublishInteractor(
            api: api,
            courseId: "1",
            moduleIds: ["moduleId1", "moduleId2"],
            action: .publish(.modulesAndItems),
            localStateRefresher: MockBulkPublishLocalStateRefresh()
        )
            .progress
        .dropFirst() // ignore first 0% state

        // THEN
        XCTAssertFailure(testee)
    }

    func testPolling() {
        let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        let publishRequestMock = api.mock(
            bulkPublishRequest,
            value: .init(progress: .init(.init(progress: .init(id: "progressId"))))
        )
        publishRequestMock.suspend()
        let pollRequest = GetBulkPublishProgressRequest(modulePublishProgressId: "progressId")
        let testee = BulkPublishInteractor(
            api: api,
            courseId: "1",
            moduleIds: ["moduleId1", "moduleId2"],
            action: .publish(.modulesAndItems),
            localStateRefresher: MockBulkPublishLocalStateRefresh(),
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        let streamCompleted = expectation(description: "Stream completed")
        let streamPublished = expectation(description: "Stream published")

        let subscription = testee
            .progress
            .collect(5)
            .sink { completion in
                streamCompleted.fulfill()
                if case .failure = completion {
                    XCTFail("Stream unexpectedly failed")
                }
            } receiveValue: { progressUpdates in
                streamPublished.fulfill()
                XCTAssertEqual(
                    progressUpdates,
                    [
                        .running(progress: 0),
                        .running(progress: 0.2),
                        .running(progress: 0.8),
                        .running(progress: 1),
                        .completed
                    ]
                )
            }

        api.mock(pollRequest,
                 error: NSError.instructureError("testError"))
        publishRequestMock.resume()

        api.mock(pollRequest,
                 value: .init(completion: 20, workflow_state: "running"))
        testScheduler.advance(by: 1.1)

        api.mock(pollRequest,
                 value: .init(completion: 80, workflow_state: "running"))
        testScheduler.advance(by: 1.1)

        api.mock(pollRequest,
                 error: NSError.instructureError("testError"))
        testScheduler.advance(by: 1.1)

        api.mock(pollRequest,
                 value: .init(completion: 100, workflow_state: "completed"))
        testScheduler.advance(by: 1.1)

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testPollingFailsAfterRetries() {
        let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        let publishRequestMock = api.mock(
            bulkPublishRequest,
            value: .init(progress: .init(.init(progress: .init(id: "progressId"))))
        )
        publishRequestMock.suspend()
        let pollRequest = GetBulkPublishProgressRequest(modulePublishProgressId: "progressId")
        let testee = BulkPublishInteractor(
            api: api,
            courseId: "1",
            moduleIds: ["moduleId1", "moduleId2"],
            action: .publish(.modulesAndItems),
            localStateRefresher: MockBulkPublishLocalStateRefresh(),
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        let streamCompleted = expectation(description: "Stream completed")
        let streamPublished = expectation(description: "Stream published")

        let subscription = testee
            .progress
            .sink { completion in
                streamCompleted.fulfill()
                if case .finished = completion {
                    XCTFail("Stream unexpectedly succeeded")
                }
            } receiveValue: { progressUpdates in
                streamPublished.fulfill()
                XCTAssertEqual(
                    progressUpdates,
                    .running(progress: 0)
                )
            }

        api.mock(pollRequest,
                 error: NSError.instructureError("testError"))
        publishRequestMock.resume()
        testScheduler.advance(by: 1.1)
        testScheduler.advance(by: 1.1)
        testScheduler.advance(by: 1.1)
        testScheduler.advance(by: 1.1)
        testScheduler.advance(by: 1.1)

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}

struct MockBulkPublishLocalStateRefresh: BulkPublishLocalStateRefresher {

    func refreshStates() -> any Publisher<Void, Error> {
        Just(()).setFailureType(to: Error.self)
    }
}
