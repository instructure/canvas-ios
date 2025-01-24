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
import XCTest

class UIAccessibilityAnnouncementTests: XCTestCase {

    func testAnnouncementRetryIfInterrupted() {
        let announcementReceived = expectation(description: "Announcement request received")
        announcementReceived.expectedFulfillmentCount = 2

        UIAccessibility.announce("Test Announcement", announcementHandler: { notificationType, announcementString in
            announcementReceived.fulfill()
            XCTAssertEqual(notificationType, .announcement)
            XCTAssertEqual(announcementString as? String, "Test Announcement")
        }, isVoiceOverRunning: {
            true
        })

        // Simulate that announcement gets interrupted by a system sound, this should trigger a retry
        postAnnouncementNotification(isSuccessful: false)

        // Simulate that announcement was successfully announced
        postAnnouncementNotification(isSuccessful: true)

        // After successful announcement no more retries should occur
        postAnnouncementNotification(isSuccessful: false)

        wait(for: [announcementReceived], timeout: 1)
    }

    private func postAnnouncementNotification(isSuccessful: Bool) {
        let userInfo: [String: Any] = [
            UIAccessibility.announcementStringValueUserInfoKey: "Test Announcement",
            UIAccessibility.announcementWasSuccessfulUserInfoKey: isSuccessful
        ]
        NotificationCenter.default.post(name: UIAccessibility.announcementDidFinishNotification, object: nil, userInfo: userInfo)
    }
}
