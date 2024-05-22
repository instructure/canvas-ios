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

public class NotificationManager {
    public static let RouteURLKey = "com.instructure.core.router.notification-url"

    public let notificationCenter: UserNotificationCenterProtocol
    public let logger: LoggerProtocol
    public var remoteToken: Data?
    public var remoteSession: LoginSession?

    public static var shared = NotificationManager(
        notificationCenter: UNUserNotificationCenter.current(),
        logger: AppEnvironment.shared.logger
    )

    init(
        notificationCenter: UserNotificationCenterProtocol,
        logger: LoggerProtocol
    ) {
        self.notificationCenter = notificationCenter
        self.logger = logger
    }
}

// MARK: Push Notifications
extension NotificationManager {
    public func registerForRemoteNotifications(application: UIApplication) {
        guard !ProcessInfo.isUITest else { return }

        notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in performUIUpdate {
            guard granted, error == nil else { return }
            #if !targetEnvironment(simulator) // Can't register on simulator
                application.registerForRemoteNotifications()
            #endif
        } }
    }

    /**
     - parameters:
        - deviceToken: The token received from Apple after we registered the device for push notifications at APNS.
     */
    public func subscribeToPushChannel(
        deviceToken: Data? = nil,
        session: LoginSession? = AppEnvironment.shared.currentSession
    ) {
        guard AppEnvironment.shared.currentSession?.isFakeStudent == false else {
            return
        }
        let newToken = deviceToken ?? remoteToken
        guard newToken != remoteToken || session != remoteSession else { return }
        unsubscribeFromPushChannel()
        remoteToken = newToken
        remoteSession = session
        guard let token = newToken, let session = session else { return }
        createPushChannel(deviceToken: token, session: session)
    }

    private func createPushChannel(deviceToken: Data, session: LoginSession, retriesLeft: Int = 4) {
        let api = API(session)
        api.makeRequest(PostCommunicationChannelRequest(pushToken: deviceToken)) { channel, _, error in
            let retryCodes = [ Int(ECONNABORTED), NSURLErrorNetworkConnectionLost ]
            if let code = (error as NSError?)?.code, retryCodes.contains(code), retriesLeft > 0 {
                return self.createPushChannel(deviceToken: deviceToken, session: session, retriesLeft: retriesLeft - 1)
            }
            guard let channelID = channel?.id.value, error == nil else {
                // Hide error alert when "Users can edit their communication channels" setting is turned off
                if let apiError = error as? APIError, case .unauthorized = apiError {
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

    private func setPushChannelDefaults(_ api: API, channelID: String) {
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

    public func unsubscribeFromPushChannel() {
        guard let token = remoteToken, let session = remoteSession else { return }
        API(session).makeRequest(DeletePushChannelRequest(pushToken: token)) { _, _, error in
            guard let error = error else { return }
            self.logger.error(error.localizedDescription)
        }
    }

    public static func routeURL(from userInfo: [AnyHashable: Any]) -> URL? {
        // Handle local notifications we know about first
        if let route = userInfo[NotificationManager.RouteURLKey] as? String {
            return URL(string: route)
        }
        if let url = userInfo["html_url"] as? String {
            return fixBetaURL(URL(string: url))
        }
        return nil
    }

    // In beta, a push notification's url may point to prod. Fix it to point to beta.
    private static func fixBetaURL(_ original: URL?) -> URL? {
        guard
            let baseURL = AppEnvironment.shared.currentSession?.baseURL,
            baseURL.host?.contains(".beta") == true,
            baseURL.host?.replacingOccurrences(of: ".beta", with: "") == original?.host,
            var components = original.map({ URLComponents.parse($0) })
        else { return original }
        components.host = baseURL.host
        return components.url ?? original
    }
}

extension UNNotificationRequest {
    public var route: String? {
        content.userInfo[NotificationManager.RouteURLKey] as? String
    }
}
