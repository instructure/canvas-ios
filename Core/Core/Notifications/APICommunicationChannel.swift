//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation

// https://canvas.instructure.com/doc/api/communication_channels.html#CommunicationChannel
public struct APICommunicationChannel: Codable {
    let address: String
    let id: ID
    let position: Int
    let type: CommunicationChannelType
    let user_id: ID
    let workflow_state: CommunicationChannelWorkflowState
}

public enum CommunicationChannelType: String, Codable {
    case chat, email, push, slack, sms, twitter, yo

    var name: String {
        switch self {
        case .chat:
            return NSLocalizedString("Chat Notifications", bundle: .core, comment: "Description for Chat communication channel")
        case .email:
            return NSLocalizedString("Email Notifications", bundle: .core, comment: "Description for email communication channel")
        case .push:
            return NSLocalizedString("Push Notifications", bundle: .core, comment: "Description for Push Notification channel")
        case .slack:
            return NSLocalizedString("Slack Notifications", bundle: .core, comment: "Description for Slack communication channel")
        case .sms:
            return NSLocalizedString("SMS Notifications", bundle: .core, comment: "Description for SMS communication channel")
        case .twitter:
            return NSLocalizedString("Twitter Notifications", bundle: .core, comment: "Description for Twitter communication channel")
        case .yo:
            return NSLocalizedString("Yo Notifications", bundle: .core, comment: "Description for Yo communication channel")
        }
    }
}

public enum CommunicationChannelWorkflowState: String, Codable {
    case active, unconfirmed
}

#if DEBUG
extension APICommunicationChannel {
    public static func make(
        address: String = "All Devices",
        id: ID = "1",
        position: Int = 1,
        type: CommunicationChannelType = .push,
        user_id: ID = "1",
        workflow_state: CommunicationChannelWorkflowState = .active
    ) -> APICommunicationChannel {
        return APICommunicationChannel(
            address: address,
            id: id,
            position: position,
            type: type,
            user_id: user_id,
            workflow_state: workflow_state
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/communication_channels.html#method.communication_channels.index
public struct GetCommunicationChannelsRequest: APIRequestable {
    public typealias Response = [APICommunicationChannel]
    public let path = "users/self/communication_channels"
}
