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
import CoreData
import XCTest
@testable import Core
@testable import Teacher

class QuizSubmissionViewModelTests: TeacherTestCase {
    private var mockInteractor: QuizSubmissionListInteractorMock!
    var testee: QuizSubmissionListViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = QuizSubmissionListInteractorMock(context: databaseClient)
        testee = QuizSubmissionListViewModel(router: router, filterValue: .all, interactor: mockInteractor)
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.submissions.count, 4)
        XCTAssertEqual(testee.filter, .all)
        XCTAssertEqual(testee.subTitle, "QuizTitle")
    }

    // MARK: - Inputs

    func testRefreshForwardedToInteractor() {
        let refreshCompleted = expectation(description: "refresh callback received")

        testee.refreshDidTrigger.send {
            refreshCompleted.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertTrue(mockInteractor.refreshCalled)
    }

    func testFilterChangeForwardedToInteractor() {
        XCTAssertEqual(mockInteractor.receivedFilter, testee.filter)

        testee.filterDidChange.send(.submitted)

        XCTAssertEqual(mockInteractor.receivedFilter, .submitted)
    }

    func testSubmissionTap() {
        XCTAssertFalse(testee.showError)
        testee.submissionDidTap()
        XCTAssertTrue(testee.showError)
    }

    func testmessageUsersTapRoute() {
        let sourceView = UIViewController()

        testee.messageUsersDidTap.send(WeakViewController(sourceView))

        XCTAssertTrue(mockInteractor.createMessageUserInfoCalled)
        wait(for: [router.routeExpectation], timeout: 1)
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "/conversations/compose"))
        XCTAssertEqual(router.calls.last?.1, sourceView)
        XCTAssertEqual(router.calls.last?.2, .modal(embedInNav: true))
    }
}

private class QuizSubmissionListInteractorMock: QuizSubmissionListInteractor {
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var submissions = CurrentValueSubject<[QuizSubmissionListItem], Never>([])
    var quizTitle = CurrentValueSubject<String, Never>("QuizTitle")
    var courseID: String = ""
    var quizID: String = ""

    private(set) var createMessageUserInfoCalled = false
    private(set) var refreshCalled = false
    private(set) var receivedFilter: QuizSubmissionListFilter?

    init(context: NSManagedObjectContext) {
        self.submissions = .init(.make(count: 4))
    }

    func refresh() -> Future<Void, Never> {
        refreshCalled = true
        return mockFuture
    }

    func setFilter(_ filter: QuizSubmissionListFilter) -> Future<Void, Never> {
        receivedFilter = filter
        return mockFuture
    }

    func createMessageUserInfo() -> Future<[String: Any], Never> {
        createMessageUserInfoCalled = true
        return Future<[String: Any], Never> { promise in
            promise(.success([:]))
        }
    }

    private var mockFuture: Future<Void, Never> {
        Future<Void, Never> { promise in
            promise(.success(()))
        }
    }
}
