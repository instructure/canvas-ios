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
import CoreData
import XCTest

class MessageDetailsViewModelTests: CoreTestCase {
    private var mockInteractor: MessageDetailsInteractorMock!
    var testee: MessageDetailsViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = MessageDetailsInteractorMock(context: databaseClient)
        testee = MessageDetailsViewModel(router: router, interactor: mockInteractor, myID: "1")
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.subject, "Test")
        XCTAssertEqual(testee.messages.count, 5)
        XCTAssertFalse(testee.starred)
    }

    func testRefreshForwardedToInteractor() {
        let refreshCompleted = expectation(description: "refresh callback received")

        testee.refreshDidTrigger.send {
            refreshCompleted.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertTrue(mockInteractor.refreshCalled)
    }

    func testStarredTap() {
        XCTAssertFalse(testee.starred)

        testee.starDidTap.send(true)

        XCTAssertEqual(mockInteractor.receivedStarred, true)
    }

    func testMoreTapped() {
        let sourceView = UIViewController()

        testee.moreTapped(viewController: WeakViewController(sourceView))

        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(sheet)
        XCTAssertEqual(sheet?.actions.count, 5)
    }
}

private class MessageDetailsInteractorMock: MessageDetailsInteractor {
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var subject = CurrentValueSubject<String, Never>("Test")
    var messages: CurrentValueSubject<[ConversationMessage], Never>
    var starred = CurrentValueSubject<Bool, Never>(false)
    var userMap: [String: ConversationParticipant] = [:]

    private(set) var refreshCalled = false
    private(set) var receivedStarred: Bool?

    init(context: NSManagedObjectContext) {
        self.messages = .init(.make(count: 5, in: context))
    }

    func refresh() -> Future<Void, Never> {
        refreshCalled = true
        return mockFuture
    }

    func updateStarred(starred: Bool) -> Future<Void, Never> {
        receivedStarred = starred
        return mockFuture
    }

    private var mockFuture: Future<Void, Never> {
        Future<Void, Never> { promise in
            promise(.success(()))
        }
    }
}
