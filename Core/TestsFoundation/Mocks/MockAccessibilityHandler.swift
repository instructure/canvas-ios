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

import UIKit
@testable import Core

public class MockAccessibilityHandler: AccessibilityNotificationHandler {

    public struct Attempt {
        let notification: UIAccessibility.Notification
        public let value: String?
    }

    public private(set) var attempts: [Attempt]
    public var isVoiceOverRunning: Bool

    public init(attempts: [Attempt] = [], isVoiceOverRunning: Bool = true) {
        self.attempts = attempts
        self.isVoiceOverRunning = isVoiceOverRunning
    }

    public func post(notification: UIAccessibility.Notification, argument: Any?) {
        let message = (argument as? NSAttributedString)?.string
        attempts.append(Attempt(notification: notification, value: message))
    }

    public func postDidFinishNotificationForLastAttempt(isSuccessful: Bool) {
        guard let message = attempts.last?.value else { return }

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
