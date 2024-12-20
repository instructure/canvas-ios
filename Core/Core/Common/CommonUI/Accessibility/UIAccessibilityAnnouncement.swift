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

public extension UIAccessibility {

    /**
     Announces the received string via VoiceOver. If the announcement is interrupted by anything this method will retry until the announcement succeeds.
     Doesn't support queueing so if an announcement is already in progress and this method is invoked, then this method will return without doing anything.
     - parameters:
        - announcement: The string to be read by VoiceOver.
        - announcementHandler: This parameter is only used for testing purposes, use its default value otherwise.
        - isVoiceOverRunning: This parameter is only used for testing purposes, use its default value otherwise.
     */
    static func announce(_ announcement: String,
                         announcementHandler: @escaping (UIAccessibility.Notification, Any?) -> Void = UIAccessibility.post(notification:argument:),
                         isVoiceOverRunning: () -> Bool = UIAccessibility.isVoiceOverRunning) {
        guard isVoiceOverRunning(), _announcementHandler == nil else { return }
        _announcementHandler = announcementHandler
        observeAnnouncementFinishedNofitication(announcement)
        _announcementHandler?(.announcement, announcement)
    }

    /**
     This is a helper method for testing purposes. The reason behind is that you can't pass around a reference of a method getter only of a function, so we wrap the UIAccessibility.isVoiceOverRunning property into a function and use this to mock the value of this property while testing the `announce` method.
     */
    static func isVoiceOverRunning() -> Bool {
        UIAccessibility.isVoiceOverRunning
    }

    private static func observeAnnouncementFinishedNofitication(_ announcement: String) {
        guard _announcementFinishedObserver == nil else { return }
        _announcementFinishedObserver = NotificationCenter.default.addObserver(forName: announcementDidFinishNotification, object: nil, queue: .main) { notification in
            guard
                let announced = notification.userInfo?[announcementStringValueUserInfoKey] as? String,
                let isSuccessful = notification.userInfo?[announcementWasSuccessfulUserInfoKey] as? Bool,
                announced == announcement
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
                _announcementHandler?(.announcement, announcement)
            }
        }
    }
}

private var _announcementFinishedObserver: Any?
private var _announcementHandler: ((UIAccessibility.Notification, Any?) -> Void)?
