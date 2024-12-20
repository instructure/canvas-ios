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

import Foundation

public typealias PageViewEventDictionary = [String: String]

public struct PageViewEvent: Codable {
    let eventName: String
    let eventDuration: TimeInterval
    var attributes: PageViewEventDictionary
    let timestamp: Date
    let userID: String
    var guid: String = Foundation.UUID().uuidString

    init(eventName: String, attributes: PageViewEventDictionary = [:], userID: String, timestamp: Date = Date(), eventDuration: TimeInterval = 0) {
        self.eventName = eventName
        self.eventDuration = eventDuration
        self.timestamp = timestamp
        self.userID = userID
        self.attributes = attributes
    }

    func apiEvent(_ token: APIPandataEventsToken, appTag: String = Bundle.main.pandataAppTag) -> APIPandataEvent {
        return APIPandataEvent.pageView(
            timestamp: timestamp,
            appTag: appTag,
            properties: APIPandataEventProperties(
                page_name: eventName,
                url: attributes["url"],
                interaction_seconds: eventDuration,
                domain: attributes["domain"],
                context_type: attributes["context_type"],
                context_id: attributes["context_id"],
                app_name: attributes["app_name"],
                real_user_id: attributes["real_user_id"],
                user_id: attributes["user_id"],
                session_id: attributes["session_id"],
                agent: attributes["agent"],
                guid: guid,
                customPageViewPath: attributes["customPageViewPath"]
            ),
            signedProperties: token.props_token
        )
    }
}
