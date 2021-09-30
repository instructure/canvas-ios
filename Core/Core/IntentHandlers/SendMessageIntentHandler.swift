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

import Intents

public class SendMessageIntentHandler: NSObject, CanvasIntentHandler, INSendMessageIntentHandling {

    public func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        guard isLoggedIn else { return } // Unfortunately, there doesn't seem to be a way to fail here if the user is not logged in
        guard let recipients = intent.recipients else {
            completion([INSendMessageRecipientResolutionResult.needsValue()])
            return
        }

        setupLastLoginCredentials()

        let requests = recipients.map { recipient in
            GetSearchRecipientsRequest(search: recipient.displayName)
        }

        var responses = [INSendMessageRecipientResolutionResult?](repeating: nil, count: requests.count)
        var completedRequests = 0

        for (index, request) in requests.enumerated() {
            env.api.makeRequest(request) { results, response, error in
                let persons: [INPerson] = results?.map { result in
                    var avatar: INImage? = nil
                    if let avatarUrl = result.avatar_url {
                        avatar = INImage(url: avatarUrl.rawValue)
                    }
                    
                    return INPerson(personHandle: INPersonHandle(value: result.id.rawValue, type: .unknown, label: INPersonHandleLabel("Canvas user ID")), nameComponents: nil, displayName: result.name, image: avatar, contactIdentifier: nil, customIdentifier: result.id.rawValue)
                } ?? []

                switch persons.count {
                case 2 ... 4:
                    responses[index] = INSendMessageRecipientResolutionResult.disambiguation(with: persons)
                case 1:
                    guard let person = persons.first else {fallthrough}
                    if person.displayName.caseInsensitiveCompare(recipients[index].displayName) == .orderedSame {
                        responses[index] = INSendMessageRecipientResolutionResult.success(with: person)
                    } else {
                        responses[index] = INSendMessageRecipientResolutionResult.confirmationRequired(with: person)
                    }
                default:
                    responses[index] = INSendMessageRecipientResolutionResult.unsupported()
                }

                completedRequests += 1

                // Call the callback once all requests have been completed
                if (completedRequests == requests.count) {
                    completion(responses as! [INSendMessageRecipientResolutionResult])
                }
            }
        }
    }

    public func resolveContent(for intent: INSendMessageIntent, with completion: (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }

    @available(iOSApplicationExtension 14.0, *)
    public func resolveOutgoingMessageType(for intent: INSendMessageIntent, with completion: @escaping (INOutgoingMessageTypeResolutionResult) -> Void) {
        guard intent.outgoingMessageType != .outgoingMessageAudio else {
            completion(INOutgoingMessageTypeResolutionResult.unsupported())
            return
        }
        
        completion(INOutgoingMessageTypeResolutionResult.success(with: .outgoingMessageText))
    }

    public func confirm(intent: INSendMessageIntent, completion: (INSendMessageIntentResponse) -> Void) {
        guard isLoggedIn else {
            completion(INSendMessageIntentResponse.init(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }

        completion(INSendMessageIntentResponse.init(code: .ready, userActivity: nil))
    }
    
    public func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        let body = PostConversationRequest.Body(subject: "", body: intent.content ?? "", recipients: intent.recipients?.map { $0.customIdentifier ?? "" } ?? [], attachment_ids: nil)
        let request = PostConversationRequest(body: body)
        
        env.api.makeRequest(request) { results, response, error in
            guard error == nil else {
                completion(INSendMessageIntentResponse(code: .failure, userActivity: nil))
                return
            }

            let userActivity = NSUserActivity(activityType: "INSendMessageIntent")
            userActivity.addUserInfoEntries(from: ["url": "/conversations/\(results?.first?.id.rawValue ?? "")"])
            completion(INSendMessageIntentResponse(code: .success, userActivity: userActivity))
        }
    }
}
