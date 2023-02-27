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

// https://canvas.instructure.com/doc/api/users.html#method.users.pandata_events_token
public struct APIPandataEventsToken: Codable, Equatable {
    public let url: URL
    public let auth_token: String
    public let props_token: String
    public let expires_at: Double
}

public struct APIPandataEvent: Codable, Equatable {
    public let timestamp: Date
    public let appTag: String
    public let eventType: APIPandataEventType
    public let properties: APIPandataEventProperties
    public let signedProperties: String

    public static func pageView(
        timestamp: Date,
        appTag: String = Bundle.main.pandataAppTag,
        properties: APIPandataEventProperties,
        signedProperties: String
    ) -> APIPandataEvent {
        return APIPandataEvent(
            timestamp: timestamp,
            appTag: appTag,
            eventType: .page_view,
            properties: properties,
            signedProperties: signedProperties
        )
    }
}

public enum APIPandataEventType: String, Codable, Equatable {
    case page_view
}

public struct APIPandataEventProperties: Codable, Equatable {
    let page_name: String
    let url: String?
    let interaction_seconds: TimeInterval
    let domain: String?
    let context_type: String?
    let context_id: String?
    let app_name: String?
    let real_user_id: String?
    let user_id: String?
    let session_id: String?
    let agent: String?
    let guid: String
    let customPageViewPath: String?

    public init(
        page_name: String,
        url: String?,
        interaction_seconds: TimeInterval,
        domain: String?,
        context_type: String?,
        context_id: String?,
        app_name: String?,
        real_user_id: String?,
        user_id: String?,
        session_id: String?,
        agent: String?,
        guid: String,
        customPageViewPath: String?
    ) {
        self.page_name = page_name
        self.url = url
        self.interaction_seconds = interaction_seconds
        self.domain = domain
        self.context_type = context_type
        self.context_id = context_id
        self.app_name = app_name
        self.real_user_id = real_user_id
        self.user_id = user_id
        self.session_id = session_id
        self.agent = agent
        self.guid = guid
        self.customPageViewPath = customPageViewPath
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.pandata_events_token
public struct PostPandataEventsTokenRequest: APIRequestable {
    public typealias Response = APIPandataEventsToken
    public struct Body: Codable {
        let app_key: String
    }

    public let method = APIMethod.post
    public let path = "users/self/pandata_events_token"
    public let body: Body?

    public init(appTag: String = Bundle.main.pandataAppTag) {
        self.body = Body(app_key: appTag)
    }
}

public struct PostPandataEventsRequest: APIRequestable {
    public typealias Response = String
    public struct Body: Codable {
        let events: [APIPandataEvent]
    }

    public let method = APIMethod.post
    public let headers: [String: String?]
    public let path: String
    public let body: Body?

    public init(token: APIPandataEventsToken, events: [APIPandataEvent]) {
        headers = [ HttpHeader.authorization: "Bearer \(token.auth_token)" ]
        path = token.url.absoluteString
        body = Body(events: events)
    }

    public func decode(_ data: Data) throws -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}
