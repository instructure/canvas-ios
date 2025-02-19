//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import UIKit
import Combine
import XCTest
import Core

class UIAccessibilityAnnouncementTests: XCTestCase {

    private var handler: MockAccessabilityHandler!
    private var subscription: AnyCancellable?

    override func setUp() {
        super.setUp()
        handler = MockAccessabilityHandler()
    }

    override func tearDown() {
        handler = nil
        subscription?.cancel()
        subscription = nil
        super.tearDown()
    }

    func testAnnouncementRetryIfInterrupted() {
        let message = "Test Announcement"

        UIAccessibility.announce(message, handler: handler)

        // Simulate that announcement gets interrupted by a system sound, this should trigger a retry
        postAnnouncementNotification(message, isSuccessful: false)

        // Simulate that announcement was successfully announced
        postAnnouncementNotification(message, isSuccessful: true)

        // After successful announcement no more retries should occur
        postAnnouncementNotification(message, isSuccessful: false)

        XCTAssertEqual(handler.attempts.count, 2)
        XCTAssertTrue(handler.attempts.allSatisfy({ $0.value == message }))
    }

    func testAnnouncementPersistently_Successful() {
        let message = "Test Persistent Announcement"
        let valuePublished = expectation(description: "Announcement finished")
        valuePublished.expectedFulfillmentCount = 1

        subscription = UIAccessibility
            .announcePersistently(
                message,
                handler: handler
            )
            .sink(receiveValue: { valuePublished.fulfill() })

        // Finished
        postAnnouncementNotification(message, isSuccessful: true)

        wait(for: [valuePublished], timeout: 2)
        XCTAssertEqual(handler.attempts.count, 1)
    }

    func testAnnouncementPersistently_MaxAttempts() {
        let message = "Test Persistent Announcement"
        let valuePublished = expectation(description: "Announcement finished")
        valuePublished.expectedFulfillmentCount = 1

        subscription = UIAccessibility
            .announcePersistently(
                message,
                maxAttempts: 3,
                handler: handler
            )
            .sink(receiveValue: { valuePublished.fulfill() })

        // Attempt 2
        postAnnouncementNotification(message, isSuccessful: false)
        // Attempt 3
        postAnnouncementNotification(message, isSuccessful: false)
        // Finish
        postAnnouncementNotification(message, isSuccessful: false)

        wait(for: [valuePublished], timeout: 2)
        XCTAssertEqual(handler.attempts.count, 3)
    }

    func testAnnouncementPersistently_MaxDuration() {
        let message = "Test Persistent Announcement"
        let valuePublished = expectation(description: "Announcement finished")
        valuePublished.expectedFulfillmentCount = 1

        subscription = UIAccessibility
            .announcePersistently(
                message,
                maxDuration: 2,
                handler: handler
            )
            .sink(receiveValue: { valuePublished.fulfill() })

        let timeElapsed = expectation(description: "Time elapsed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            timeElapsed.fulfill()
        }

        wait(for: [timeElapsed, valuePublished], timeout: 5)
        XCTAssertEqual(handler.attempts.count, 1)
    }

    private func postAnnouncementNotification(
        _ message: String,
        isSuccessful: Bool
    ) {
        let userInfo: [String: Any] = [
            UIAccessibility.announcementStringValueUserInfoKey: message,
            UIAccessibility.announcementWasSuccessfulUserInfoKey: isSuccessful
        ]
        NotificationCenter.default.post(
            name: UIAccessibility.announcementDidFinishNotification,
            object: nil,
            userInfo: userInfo
        )
    }
}

class MockAccessabilityHandler: AccessibilityHandler {

    struct Attempt {
        let notificaiton: UIAccessibility.Notification
        let value: String?
    }

    private(set) var attempts: [Attempt] = []
    func post(notification: UIAccessibility.Notification, argument: Any?) {
        let message = (argument as? NSAttributedString)?.string
        attempts.append(Attempt(notificaiton: notification, value: message))
    }
    
    var isVoiceOverRunning: Bool = true
}
