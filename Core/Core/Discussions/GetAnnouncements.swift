//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import CoreData

public class GetAnnouncements: CollectionUseCase {
    public typealias Model = DiscussionTopic

    var contextCodes: [String]?

    public var cacheKey: String? {
        let codes = contextCodes?.joined(separator: ",") ?? ""
        return "get-announcements-\(codes)"
    }
    public var request: GetAnnouncementsRequest
    public var scope = Scope(predicate: .all, order: [])//TODO order

    public init(contextCodes: [String]) {
        self.contextCodes = contextCodes
        request = GetAnnouncementsRequest(contextCodes: contextCodes)
        print(contextCodes)
    }
}

public struct GetAnnouncementsRequest: APIRequestable {
    public typealias Response = [APIDiscussionTopic]
    var contextCodes: [String] = []

    public init(contextCodes: [String]) {
        self.contextCodes = contextCodes
    }

    public var path = "announcements"
    public var query: [APIQueryItem] {
        [
            .array("context_codes", contextCodes),
        ]
    }
}
