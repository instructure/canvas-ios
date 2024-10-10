//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import AWSLambda
import AWSSNS
import Foundation

// MARK: Push Notifications
extension PushNotificationsInteractor {
    func checkIfShouldCreateEmailChannelForPush(session: LoginSession) {
        let api = API(session)
        api.makeRequest(GetCommunicationChannelsRequest()) { [weak self] response, _, error in
            if error == nil {
                // check if we have needed channel already
                // ToDo: change to prod domain for release
                if let domain = Secret.customPushDomain.string,
                    !domain.isEmpty,
                    let generatedPushChannel = response?.first(where: { $0.address.contains("@\(domain)") }) {
                    self?.emailAsPushChannelID = generatedPushChannel.id.value
                } else {
                    let pushChannel = response?.first(where: { $0.type == .push })
                    // need to create email channel
                    self?.createUserEmailChannel(session: session, completion: { [weak self] success, channelID in
                        if success,
                            let emailChannelID = channelID,
                            let pushChannelID = pushChannel?.id.value {
                            // need to copy settings from push channel to new created email channel
                            self?.copyChannelSettings(from: pushChannelID, to: emailChannelID, session: session)
                        }
                    })
                }
            } else {
                print("!!! user's channels getting error: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    func copyChannelSettings(from pushChannelID: String, to emailChannelID: String, session: LoginSession) {
        let api = API(session)
        emailAsPushChannelID = emailChannelID
        api.makeRequest(GetNotificationPreferencesRequest(channelID: pushChannelID)) { response, _, error in
            let allowedTypes = [
                "announcement",
                "appointment_availability",
                "appointment_cancelations",
                "calendar",
                "conversation_message",
                "course_content",
                "due_date",
                "grading",
                "invitation",
                "student_appointment_signups",
                "submission_comment",
                "discussion_mention"
            ]
            if error == nil && response != nil,
               let notif_pref_immediately = response?.notification_preferences.filter({ allowedTypes.contains($0.category ?? "") }).filter({ $0.frequency == .immediately }) {
                    api.makeRequest(PutNotificationPreferencesRequest(
                        channelID: emailChannelID,
                        notifications: notif_pref_immediately.compactMap({ $0.notification }),
                        frequency: .immediately)) { _, _, error in
                            if error == nil {
                                print("!!! push notifications settings was copied successful")
                            } else {
                                print("!!! push notifications settings copying error: \(String(describing: error?.localizedDescription))")
                            }
                        }
            }
        }
    }

    func createUserEmailChannel(session: LoginSession, completion: @escaping (Bool, String?) -> Void) {
        if let request = AWSLambdaInvocationRequest() {
            request.functionName = "mobilecanvas_createUserChannel_prod"
            request.invocationType = .requestResponse
            let params: [String: Any] = [
                "userid": session.userID,
                "domain": session.clearDomain
            ]
            if let payload = try? JSONSerialization.data(withJSONObject: params, options: []) {
                request.payload = payload
                AWSLambda(forKey: "myLambda").invoke(request) { response, error in
                    if error == nil,
                        let jsonData = response?.payload as? [String: Any],
                        let body = jsonData["body"] as? String,
                        let bodyData = body.data(using: .utf8),
                        let jsonBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
                        let channelId = jsonBody["id"] as? Int {
                        completion(true, "\(channelId)")
                    } else {
                        completion(false, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        } else {
            completion(false, nil)
        }
    }

    func createDevicePlatformEndpoint(deviceToken token: Data, session: LoginSession) {
        deviceTokenString = token.hexString
        var isReleaseString: String = ""
        #if DEBUG
        isReleaseString = "false"
        #else
        isReleaseString = "true"
        #endif
        if let request = AWSLambdaInvocationRequest() {
            request.functionName = "mobilecanvas_createPlatformEndpoint_prod"
            request.invocationType = .requestResponse
            let params: [String: Any] = [
                "userid": session.userID,
                "domain": session.clearDomain,
                "osType": "ios",
                "deviceToken": deviceTokenString ?? token.hexString,
                "isRelease": isReleaseString
            ]
            if let payload = try? JSONSerialization.data(withJSONObject: params, options: []) {
                request.payload = payload
                AWSLambda(forKey: "myLambda").invoke(request) { _, _ in }
            }
        }
    }

    public func deleteDevicePlatformEndpoint(session: LoginSession) {
        guard let deviceToken = deviceTokenString else { return }
        if let request = AWSLambdaInvocationRequest() {
            request.functionName = "mobilecanvas_deletePlatformEndpoint_prod"
            request.invocationType = .requestResponse
            let params: [String: Any] = [
                "userid": session.userID,
                "domain": session.clearDomain,
                "deviceToken": deviceToken
            ]
            if let payload = try? JSONSerialization.data(withJSONObject: params, options: []) {
                request.payload = payload
                AWSLambda(forKey: "myLambda").invoke(request) { _, _ in }
            }
        }
        loginSession = nil
    }
}
