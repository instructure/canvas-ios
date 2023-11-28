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

import Foundation
import Combine
@testable import Core
import CoreData
import XCTest

class ComposeMessageViewModelTests: CoreTestCase {
    private var mockInteractor: ComposeMessageInteractorMock!
    var testee: ComposeMessageViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = ComposeMessageInteractorMock(context: databaseClient)
        testee = ComposeMessageViewModel(router: router, interactor: mockInteractor)
    }

    func testValidationForSubject() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.selectedRecipient.accept(Recipient(searchRecipient: SearchRecipient.make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.subject = ""
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testValidationForBody() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        testee.selectedRecipient.accept(Recipient(searchRecipient: SearchRecipient.make()))
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.bodyText = ""
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testValidationForRecipients() {
        XCTAssertEqual(testee.sendButtonActive, false)
        testee.selectedContext = RecipientContext(course: Course.make())
        let recipient = Recipient(searchRecipient: SearchRecipient.make())
        testee.selectedRecipient.accept(recipient)
        testee.subject = "Test subject"
        testee.bodyText = "Test body"
        XCTAssertEqual(testee.sendButtonActive, true)
        testee.removeRecipientButtonDidTap(recipient: recipient)
        print(testee.recipients)
        XCTAssertEqual(testee.sendButtonActive, false)
    }

    func testSuccesfulSend() {
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        XCTAssertEqual(mockInteractor.isMessageSent, false)
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))
        XCTAssertEqual(mockInteractor.isMessageSent, true)
    }

    func testFailedSend() {
        mockInteractor.isSuccessfulMockFuture = false
        testee.selectedContext = RecipientContext(course: Course.make())
        let sourceView = UIViewController()
        testee.sendButtonDidTap.accept(WeakViewController(sourceView))

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? UIAlertController
        XCTAssertNotNil(dialog)
        XCTAssertEqual(dialog?.title, "Message could not be sent")
        XCTAssertEqual(dialog?.message, "Please try again!")
        XCTAssertEqual(dialog?.actions.count, 1)
        XCTAssertEqual(dialog?.actions.first?.title, "OK")
    }

    func testReplyInit() {
        testee = ComposeMessageViewModel(router: router, conversation: .make(), author: "2", interactor: mockInteractor)

        XCTAssertEqual(testee.selectedContext?.context.id, "1")
        XCTAssertEqual(testee.recipients.count, 1)
    }
}

private class ComposeMessageInteractorMock: ComposeMessageInteractor {
    var state: CurrentValueSubject<Core.StoreState, Never>
    var courses: CurrentValueSubject<[Core.InboxCourse], Never>

    var isSuccessfulMockFuture = true
    var isMessageSent = false

    init(context: NSManagedObjectContext) {
        self.state = .init(.data)
        self.courses = .init(.make(count: 5, in: context))
    }

    func send(parameters: MessageParameters) -> Future<Void, Error> {
        isMessageSent = true
        return mockFuture
    }

    private var mockFuture: Future<Void, Error> {
        isSuccessfulMockFuture ? mockSuccessFuture : mockFailedFuture
    }

    private var mockFailedFuture: Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.failure("Fail"))
        }
    }

    private var mockSuccessFuture: Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.success(()))
        }
    }
}
