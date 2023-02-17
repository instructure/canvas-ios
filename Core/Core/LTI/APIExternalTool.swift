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

public struct APIExternalTool: Codable, Equatable {
    public let id: ID
    public let name: String
    public let domain: String?
    public let url: URL?

    public var arc: Bool {
        return domain?.contains("arc.instructure.com") == true
    }
}

public struct APIGetSessionlessLaunchResponse: Codable, Equatable {
    public let name: String?
    public let url: URL
}

public struct APIExternalToolLaunch: Codable, Equatable {
    let definition_id: ID
    let domain: String?
    let placements: [String: APIExternalToolLaunchPlacement]
}

struct APIExternalToolLaunchPlacement: Codable, Equatable {
    let title: String
    let url: URL
}

#if DEBUG
extension APIExternalTool {
    public static func make(
        id: ID = "1",
        name: String = "External 1",
        domain: String? = nil,
        url: URL = URL(string: "canvas.instructure.com/external_tools/1")!
    ) -> APIExternalTool {
        return APIExternalTool(
            id: id,
            name: name,
            domain: domain,
            url: url
        )
    }
}

extension APIGetSessionlessLaunchResponse {
    static func make(
        name: String? = nil,
        url: URL = URL(string: "https://canvas.instructure.com")!
    ) -> APIGetSessionlessLaunchResponse {
        APIGetSessionlessLaunchResponse(name: name, url: url)
    }
}

extension APIExternalToolLaunch {
    static func make(
        definition_id: ID = "1",
        domain: String? = nil,
        placements: [String: APIExternalToolLaunchPlacement] = ["1": .init(title: "Studio", url: URL(string: "/studio")!)]
    ) -> Self {
        return Self(definition_id: definition_id, domain: domain, placements: placements)
    }
}
#endif

public struct GetSessionlessLaunchURLRequest: APIRequestable {
    public typealias Response = APIGetSessionlessLaunchResponse

    let context: Context
    let id: String?
    let url: URL?
    let assignmentID: String?
    let moduleItemID: String?
    let launchType: LaunchType?
    let resourceLinkLookupUUID: String?

    public enum LaunchType: String {
        case assessment, module_item, course_navigation
    }

    public var path: String {
        return "\(context.pathComponent)/external_tools/sessionless_launch"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []

        if let id = id {
            query.append(.value("id", id))
        }

        if let launchType = launchType {
            query.append(.value("launch_type", launchType.rawValue))
        }

        if let url = url {
            query.append(.value("url", url.absoluteString))
        }

        if let assignmentID = assignmentID {
            query.append(.value("assignment_id", assignmentID))
        }

        if let moduleItemID = moduleItemID {
            query.append(.value("module_item_id", moduleItemID))
        }

        if let resourceLinkLookupUUID = resourceLinkLookupUUID {
            query.append(.value("resource_link_lookup_uuid", resourceLinkLookupUUID))
        }

        return query
    }
}

public struct GetExternalToolsRequest: APIRequestable {
    public typealias Response = [APIExternalTool]

    let context: Context
    let includeParents: Bool
    let perPage: Int

    public init(context: Context, includeParents: Bool, perPage: Int = 10) {
        self.context = context
        self.includeParents = includeParents
        self.perPage = perPage
    }

    public var cacheKey: String {
        return "\(context.canvasContextID)_external_tools"
    }

    public var path: String {
        return "\(context.pathComponent)/external_tools"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .perPage(perPage),
        ]
        if includeParents {
            query.append(.value("include_parents", "true"))
        }
        return query
    }
}

public struct GetGlobalNavExternalToolsRequest: APIRequestable {
    public typealias Response = [APIExternalToolLaunch]

    public let path = "accounts/self/lti_apps/launch_definitions"
    public let query = [APIQueryItem.array("placements", ["global_navigation"])]
}
