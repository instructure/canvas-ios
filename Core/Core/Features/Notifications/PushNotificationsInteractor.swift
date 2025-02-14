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
        notificationCenterDelegate: UserNotificationCenterDelegate(),
        logger: AppEnvironment.shared.logger
    )

    public let notificationCenter: UserNotificationCenterProtocol
    private let notificationCenterDelegate: UserNotificationCenterDelegate

    private let logger: LoggerProtocol
    private var deviceToken: Data? {
        didSet {
            subscribeToCanvasPushNotificationsIfNecessary()
        }
    }

    private var loginSession: LoginSession? {
        didSet {
            subscribeToCanvasPushNotificationsIfNecessary()
        }
    }

    init(
        notificationCenter: UserNotificationCenterProtocol,
        notificationCenterDelegate: UserNotificationCenterDelegate,
        logger: LoggerProtocol
    ) {
        self.notificationCenter = notificationCenter
        self.notificationCenterDelegate = notificationCenterDelegate
        self.notificationCenter.delegate = notificationCenterDelegate
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
    }

    public func userDidLogin(
        loginSession: LoginSession
    ) {
        if loginSession.isFakeStudent {
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
    }

    public func unsubscribeFromCanvasPushNotifications() {
        guard let deviceToken, let loginSession else {
            return
        }
        let api = API(loginSession)
        self.loginSession = nil
        api.makeRequest(DeletePushChannelRequest(pushToken: deviceToken)) { _, _, error in
            guard let error else { return }
            self.logger.error(error.localizedDescription)
        }
    }

    private func subscribeToCanvasPushNotificationsIfNecessary() {
        guard let deviceToken, let loginSession else {
            return
        }

        createPushChannel(deviceToken: deviceToken, session: loginSession)
    }

    private func createPushChannel(
        deviceToken: Data,
        session: LoginSession,
        retriesLeft: Int = 4
    ) {
        let api = API(session)
        api.makeRequest(PostCommunicationChannelRequest(pushToken: deviceToken)) { channel, _, error in
            let retryCodes = [Int(ECONNABORTED), NSURLErrorNetworkConnectionLost]
            if let code = (error as NSError?)?.code, retryCodes.contains(code), retriesLeft > 0 {
                return self.createPushChannel(deviceToken: deviceToken, session: session, retriesLeft: retriesLeft - 1)
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
            let ignore = ["registration", "summaries", "other", "migration", "alert", "reminder", "recording_ready"]
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
