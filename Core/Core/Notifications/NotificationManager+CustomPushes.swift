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

import AWSLambda
import AWSSNS
import Foundation

// MARK: Push Notifications
extension NotificationManager {
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
                "discussion_mention",
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
            request.functionName = "createUserChannel"
            request.invocationType = .requestResponse
            let params: [String: Any] = [
                "userid": session.userID,
                "domain": session.clearDomain,
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

    func subscribeToUserSNSTopic(deviceToken token: Data, session: LoginSession) {
        guard subscriptionArn == nil || subscriptionArn?.isEmpty == true else { return }
        if let requestApp = AWSSNSCreatePlatformEndpointInput(),
            var appARN = Secret.appArnTemplate.string {
            requestApp.token = token.hexString
            #if DEBUG
            appARN = appARN.replacingOccurrences(of: "{SCHEME}", with: "APNS_SANDBOX")
            #else
            appARN = appARN.replacingOccurrences(of: "{SCHEME}", with: "APNS")
            #endif
            requestApp.platformApplicationArn = appARN
            let sns = AWSSNS(forKey: "mySNS")
            sns.createPlatformEndpoint(requestApp).continueWith(executor: AWSExecutor.mainThread()) { response in
                if let error = response.error {
                    print("!!! Create platform endpoint error: " + error.localizedDescription)
                } else if let endpointArn = response.result?.endpointArn {
                    if let requestTopic = AWSSNSCreateTopicInput() {
                        let baseUrlTopic = session.clearDomain.replacingOccurrences(of: ".", with: "_")
                        requestTopic.name = "icanvas_mobile_\(baseUrlTopic)_\(session.userID)"
                        sns.createTopic(requestTopic).continueWith(executor: AWSExecutor.mainThread()) { response in
                            if let error = response.error {
                                print("!!! Create topic error: " + error.localizedDescription)
                            } else if let topicARN = response.result?.topicArn {
                                if let requestSubscribe = AWSSNSSubscribeInput() {
                                    requestSubscribe.endpoint = endpointArn
                                    requestSubscribe.protocols = "application"
                                    requestSubscribe.topicArn = topicARN
                                    sns.subscribe(requestSubscribe).continueWith(executor: AWSExecutor.mainThread()) { response in
                                        if let error = response.error {
                                            print("!!! Topic subscription error: " + error.localizedDescription)
                                        } else if let subscriptionArn = response.result?.subscriptionArn {
                                            self.subscriptionArn = subscriptionArn
                                            print("!!! Successful subscription to arn: \(subscriptionArn)")
                                        }
                                        return nil
                                    }
                                }
                            }
                            return nil
                        }
                    }
                }
                return nil
            }
        }
    }

    public func unsubscribeFromUserSNSTopic() {
        guard remoteToken != nil, remoteSession != nil else { return }
        let sns = AWSSNS(forKey: "mySNS")
        if let unsubscribeRequest = AWSSNSUnsubscribeInput(),
            let subscrArn = subscriptionArn,
            !subscrArn.isEmpty {
            unsubscribeRequest.subscriptionArn = subscrArn
            sns.unsubscribe(unsubscribeRequest)
            print("!!! Sent unsubscribe SNS request for arn: \(subscrArn)")
            subscriptionArn = ""
        }
    }
}
