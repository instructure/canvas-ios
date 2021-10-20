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

extension INPerson {
    convenience init(_ searchRecipient: APISearchRecipient) {
        var avatar: INImage?
        if let avatarUrl = searchRecipient.avatar_url {
            avatar = INImage(url: avatarUrl.rawValue)
        }

        self.init(personHandle: INPersonHandle(value: searchRecipient.id.rawValue, type: .unknown, label: INPersonHandleLabel("Canvas user ID")),
                  nameComponents: nil,
                  displayName: searchRecipient.name,
                  image: avatar,
                  contactIdentifier: nil,
                  customIdentifier: searchRecipient.id.rawValue)
    }
}

public class SendMessageIntentHandler: NSObject, CanvasIntentHandler, INSendMessageIntentHandling {
    public func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        guard isLoggedIn else { return } // Unfortunately, there doesn't seem to be a way to fail here if the user is not logged in
        guard let recipients = intent.recipients else {
            completion([.needsValue()])
            return
        }

        setupLastLoginCredentials()

        let requests = recipients.map { GetSearchRecipientsRequest(search: $0.displayName) }

        var responses = [INSendMessageRecipientResolutionResult](repeating: .unsupported(), count: requests.count)

        let requestGroup = DispatchGroup()
        for (index, request) in requests.enumerated() {
            requestGroup.enter()
            env.api.makeRequest(request) { results, _, error in
                let persons: [INPerson] = error == nil ? results?.map { INPerson($0) } ?? [] : []

                switch persons.count {
                case 2 ... Int.max:
                    responses[index] = .disambiguation(with: persons)
                case 1:
                    guard let person = persons.first else {fallthrough}
                    if person.displayName.caseInsensitiveCompare(recipients[index].displayName) == .orderedSame {
                        responses[index] = .success(with: person)
                    } else {
                        responses[index] = .confirmationRequired(with: person)
                    }
                default:
                    responses[index] = .unsupported()
                }

                requestGroup.leave()
            }
        }

        requestGroup.notify(queue: .main) {
            completion(responses)
        }
    }

    public func resolveContent(for intent: INSendMessageIntent, with completion: (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(.success(with: text))
        } else {
            completion(.needsValue())
        }
    }

    @available(iOSApplicationExtension 14.0, *)
    public func resolveOutgoingMessageType(for intent: INSendMessageIntent, with completion: @escaping (INOutgoingMessageTypeResolutionResult) -> Void) {
        guard intent.outgoingMessageType != .outgoingMessageAudio else {
            completion(.unsupported())
            return
        }

        completion(.success(with: .outgoingMessageText))
    }

    public func confirm(intent: INSendMessageIntent, completion: (INSendMessageIntentResponse) -> Void) {
        guard isLoggedIn else {
            completion(INSendMessageIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }

        completion(INSendMessageIntentResponse(code: .ready, userActivity: nil))
    }

    public func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        let body = PostConversationRequest.Body(subject: "", body: intent.content ?? "", recipients: intent.recipients?.map { $0.customIdentifier ?? "" } ?? [], attachment_ids: nil)
        let request = PostConversationRequest(body: body)

        env.api.makeRequest(request) { results, _, error in
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
