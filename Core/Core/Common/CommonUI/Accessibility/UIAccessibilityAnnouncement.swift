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

import Combine
import UIKit

public protocol AccessibilityNotificationHandler {
    func post(notification: UIAccessibility.Notification, argument: Any?)
    var isVoiceOverRunning: Bool { get }
}

public struct DefaultAccessibilityNotificationHandler: AccessibilityNotificationHandler {
    public init() {}

    public func post(notification: UIAccessibility.Notification, argument: Any?) {
        UIAccessibility.post(notification: notification, argument: argument)
    }

    public var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
}

public extension UIAccessibility {

    /**
     Announces the received string via VoiceOver. If the announcement is interrupted by anything this method will retry until the announcement succeeds.
     Doesn't support queueing so if an announcement is already in progress and this method is invoked, then this method will return without doing anything.
     - parameters:
        - announcementMessage: The string to be read by VoiceOver.
        - handler: This parameter is only used for testing purposes, use its default value otherwise.
     */
    static func announce(
        _ announcementMessage: String,
        handler: AccessibilityNotificationHandler = DefaultAccessibilityNotificationHandler()
    ) {
        guard handler.isVoiceOverRunning, _announcementHandler == nil else { return }
        _announcementHandler = handler

        let announcement = announcementMessage.asAnnouncement()
        observeAnnouncementFinishedNofitication(announcement)
        _announcementHandler?.post(notification: .announcement, argument: announcement)
    }

    private static func observeAnnouncementFinishedNofitication(_ announcement: NSAttributedString) {
        guard _announcementFinishedObserver == nil else { return }
        _announcementFinishedObserver = NotificationCenter.default.addObserver(forName: announcementDidFinishNotification, object: nil, queue: .main) { notification in
            guard
                let announced = notification.userInfo?[announcementStringValueUserInfoKey] as? String,
                let isSuccessful = notification.userInfo?[announcementWasSuccessfulUserInfoKey] as? Bool,
                announced == announcement.string
            else {
                return
            }

            if isSuccessful {
                if let announcementFinishedObserver = _announcementFinishedObserver {
                    NotificationCenter.default.removeObserver(announcementFinishedObserver)
                }
                _announcementFinishedObserver = nil
                _announcementHandler = nil
            } else {
                _announcementHandler?.post(notification: .announcement, argument: announcement)
            }
        }
    }

    /**
     Attempts to announces the received string via VoiceOver then publishes a Void value on read out completion.
     It will post completion value if maximum attempts were tried, or if maximum duration was elapsed.
     - parameters:
        - message: The string to be read by VoiceOver.
        - maxAttempts: Maximum amount of attempts before publishing completion value.
        - maxDuration: Maximum duration to wait for the read out before publishing completion.
        - handler: This parameter is only used for testing purposes, use its default value otherwise.
     */
    static func announcePersistently(
        _ message: String,
        maxAttempts: Int = 3,
        maxDuration: TimeInterval = 5,
        handler: AccessibilityNotificationHandler = DefaultAccessibilityNotificationHandler()
    ) -> AnyPublisher<Void, Never> {
        guard handler.isVoiceOverRunning else {
            return Just(Void()).eraseToAnyPublisher()
        }

        func postAnnouncement() {
            handler.post(notification: .announcement, argument: message.asAnnouncement())
        }

        postAnnouncement()

        let readoutPublisher = NotificationCenter
            .default
            .publisher(for: UIAccessibility.announcementDidFinishNotification)
            .filter({ notification in
                if let announced = notification.userInfo?[announcementStringValueUserInfoKey] as? String,
                   announced == message { return true }
                return false
            })
            .scan((0, false), { pair, notification in
                let success = (notification.userInfo?[announcementWasSuccessfulUserInfoKey] as? Bool) ?? false
                let attempts = pair.0 + 1
                return (attempts, success)
            })
            .flatMap { attempts, isSuccessful in
                if isSuccessful || attempts >= maxAttempts {
                    return Just(Void()).eraseToAnyPublisher()
                } else {
                    postAnnouncement()
                    return Empty<Void, Never>().eraseToAnyPublisher()
                }
            }

        let duration = OperationQueue.SchedulerTimeType.Stride(maxDuration)
        let delayPublisher = Just(Void())
            .delay(for: duration, scheduler: OperationQueue.main)

        return Publishers
            .Merge(readoutPublisher, delayPublisher)
            .eraseToAnyPublisher()
    }
}

private extension String {
    func asAnnouncement() -> NSAttributedString {
        return NSAttributedString(
            string: self,
            attributes: [
                .accessibilitySpeechQueueAnnouncement: true
            ]
        )
    }
}

private var _announcementFinishedObserver: Any?
private var _announcementHandler: AccessibilityNotificationHandler?
