//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Foundation
import UserNotifications

public class PushNotificationsInteractor {
    public static var shared = PushNotificationsInteractor(
        notificationCenter: UNUserNotificationCenter.current(),
        logger: AppEnvironment.shared.logger
    )

    public let notificationCenter: UserNotificationCenterProtocol

    private let logger: LoggerProtocol
    private var deviceToken: Data?
    private var loginSession: LoginSession?
    private var api: API?

    init(
        notificationCenter: UserNotificationCenterProtocol,
        logger: LoggerProtocol
    ) {
        self.notificationCenter = notificationCenter
        self.logger = logger
    }

    /**
     - parameters:
        - deviceToken: The token received from Apple after we registered the device for push notifications at APNS.
     */
    public func applicationDidRegisterForPushNotifications(
        deviceToken: Data
    ) {
        if self.deviceToken == deviceToken {
            // The device token is already registered so we either
            // already subscribed for pushes or wait for the session token
            return
        }

        self.deviceToken = deviceToken
        subscribeToCanvasPushNotificationsIfNecessary()
    }

    public func userDidLogin(
        api: API
    ) {
        guard
            let loginSession = api.loginSession,
            !loginSession.isFakeStudent
        else {
            return
        }

        if self.loginSession == loginSession {
            // This could happen if switch user was triggered
            // but after that the very same user logged in again.
            // Since we still have the login session saved we know
            // for sure that we haven't unsubscribed from pushes.
            return
        }

        self.loginSession = loginSession
        self.api = api
        subscribeToCanvasPushNotificationsIfNecessary()
    }

    public func unsubscribeFromCanvasPushNotifications() {
        guard let deviceToken, let api else {
            return
        }
        api.makeRequest(DeletePushChannelRequest(pushToken: deviceToken)) { _, _, error in
            guard let error else { return }
            self.logger.error(error.localizedDescription)
        }
        loginSession = nil
        self.api = nil
    }

    private func subscribeToCanvasPushNotificationsIfNecessary() {
        guard let deviceToken, let api else {
            return
        }

        createPushChannel(deviceToken: deviceToken, api: api)
    }

    private func createPushChannel(
        deviceToken: Data,
        api: API,
        retriesLeft: Int = 4
    ) {
        api.makeRequest(PostCommunicationChannelRequest(pushToken: deviceToken)) { channel, _, error in
            let retryCodes = [ Int(ECONNABORTED), NSURLErrorNetworkConnectionLost ]
            if let code = (error as NSError?)?.code, retryCodes.contains(code), retriesLeft > 0 {
                return self.createPushChannel(deviceToken: deviceToken, api: api, retriesLeft: retriesLeft - 1)
            }
            guard let channelID = channel?.id.value, error == nil else {
                // Hide error alert when "Users can edit their communication channels" setting is turned off
                if error?.isForbidden == true {
                    return
                } else if error.isPushNotConfigured {
                    return
                } else {
                    return AppEnvironment.shared.reportError(error)
                }
            }
            api.makeRequest(GetNotificationDefaultsFlagRequest()) { data, _, error in
                guard data == nil || error != nil else { return } // already set up defaults
                self.setPushChannelDefaults(api, channelID: channelID)
            }
        }
    }

    private func setPushChannelDefaults(
        _ api: API,
        channelID: String
    ) {
        api.makeRequest(GetNotificationPreferencesRequest(channelID: channelID)) { response, _, error in
            if let error = error {
                return self.logger.error(error.localizedDescription)
            }
            guard let preferences = response?.notification_preferences else { return }
            let ignore = [ "registration", "summaries", "other", "migration", "alert", "reminder", "recording_ready" ]
            let notifications = preferences.compactMap {
                ignore.contains($0.category ?? "") ? nil : $0.notification
            }
            let req = PutNotificationPreferencesRequest(channelID: channelID, notifications: notifications, frequency: .immediately)
            api.makeRequest(req) { _, _, error in
                if let error = error { return self.logger.error(error.localizedDescription) }
                api.makeRequest(PutNotificationDefaultsFlagRequest()) { _, _, error in
                    if let error = error { self.logger.error(error.localizedDescription) }
                }
            }
        }
    }
}
