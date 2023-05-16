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
@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncInteractorLiveTests: CoreTestCase {
    private var assignmentsInteractor: CourseSyncAssignmentsInteractorMock!
    private var pagesInteractor: CourseSyncPagesInteractorMock!
    private var entries: [CourseSyncSelectorEntry]!

    override func setUp() {
        assignmentsInteractor = CourseSyncAssignmentsInteractorMock()
        pagesInteractor = CourseSyncPagesInteractorMock()
        entries = [
            CourseSyncSelectorEntry(
                name: "1",
                id: "1",
                tabs: [
                    .init(id: "1", name: "Assignments", type: .assignments),
                    .init(id: "2", name: "Pages", type: .pages)
                ],
                files: []
            )
        ]
    }

    override func tearDown() {
        assignmentsInteractor = nil
        pagesInteractor = nil
        entries = []
    }

    func testDownloadState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 4
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[1].state, .loading)

        assignmentsInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .loading)

        pagesInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .downloaded)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testAssignmentErrorState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 3
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[1].state, .loading)

        assignmentsInteractor.publisher.send(completion: .failure(NSError.instructureError("Assignment error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[0].state, .error)
        XCTAssertEqual(entries[0].tabs[1].state, .loading)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }

    func testPagesErrorState() {
        let testee = CourseSyncInteractorLive(
            pagesInteractor: pagesInteractor,
            assignmentsInteractor: assignmentsInteractor
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 3
        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { val in
                    self.entries = val
                    expectation.fulfill()
                }
            )

        XCTAssertEqual(entries[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[1].state, .loading)

        pagesInteractor.publisher.send(completion: .failure(NSError.instructureError("Pages error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[0].state, .loading)
        XCTAssertEqual(entries[0].tabs[1].state, .error)

        waitForExpectations(timeout: 2)
        subscription.cancel()
    }
}

private class CourseSyncPagesInteractorMock: CourseSyncPagesInteractor {
    let publisher = PassthroughSubject<Void, Error>()

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        publisher.eraseToAnyPublisher()
    }
}

private class CourseSyncAssignmentsInteractorMock: CourseSyncAssignmentsInteractor {
    let publisher = PassthroughSubject<Void, Error>()

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        publisher.eraseToAnyPublisher()
    }
}
