//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Core
@testable import Horizon
import XCTest

final class HCourseSyncInteractorAdapterTests: HorizonTestCase {

    private static let testData = (
        entry1: CourseSyncEntry(name: "name 1", id: "id 1", hasFrontPage: false, tabs: [], files: []),
        entry2: CourseSyncEntry(name: "name 2", id: "id 2", hasFrontPage: false, tabs: [], files: [])
    )
    private lazy var testData = Self.testData

    private var wrapped: MockHCourseSyncInteractor!
    private var testee: HCourseSyncInteractorAdapter!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        wrapped = MockHCourseSyncInteractor()
        testee = HCourseSyncInteractorAdapter(wrapped: wrapped)
        subscriptions = []
    }

    override func tearDown() {
        testee = nil
        wrapped = nil
        subscriptions = nil
        super.tearDown()
    }

    // MARK: - downloadContent

    func test_downloadContent_shouldReturnEntriesImmediately() {
        let entries = [testData.entry1, testData.entry2]
        var received: [CourseSyncEntry]?

        testee.downloadContent(for: entries)
            .sink { received = $0 }
            .store(in: &subscriptions)

        XCTAssertEqual(received, entries)
    }

    func test_downloadContent_shouldNotPostOfflineSyncCompletedBeforeWrappedCompletes() {
        var notificationReceived = false
        NotificationCenter.default
            .publisher(for: .OfflineSyncCompleted)
            .sink { _ in notificationReceived = true }
            .store(in: &subscriptions)

        testee.downloadContent(for: [testData.entry1])
            .sink { _ in }
            .store(in: &subscriptions)

        XCTAssertEqual(notificationReceived, false)
    }

    func test_downloadContent_shouldPostOfflineSyncCompletedWhenWrappedCompletes() {
        let notificationExpectation = expectation(
            forNotification: .OfflineSyncCompleted,
            object: nil
        )

        testee.downloadContent(for: [testData.entry1])
            .sink { _ in }
            .store(in: &subscriptions)

        wrapped.downloadSubject.send(completion: .finished)

        wait(for: [notificationExpectation], timeout: 1)
    }

    // MARK: - cancel

    func test_cancel_shouldCancelWrappedInteractor() {
        testee.downloadContent(for: [testData.entry1])
            .sink { _ in }
            .store(in: &subscriptions)

        testee.cancel()

        XCTAssertEqual(wrapped.cancelSyncCalled, true)
    }
}

// MARK: - Private helpers

private final class MockHCourseSyncInteractor: HCourseSyncInteractor {
    let downloadSubject = PassthroughSubject<Void, Never>()
    private(set) var cancelSyncCalled = false

    func downloadContent() -> AnyPublisher<Void, Never> {
        downloadSubject.eraseToAnyPublisher()
    }

    func cancelSync() {
        cancelSyncCalled = true
    }
}
