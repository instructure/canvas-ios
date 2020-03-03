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

public struct GetSessionlessLaunchURLRequest: APIRequestable {
    public typealias Response = APIGetSessionlessLaunchResponse

    let context: Context
    let id: String?
    let url: URL?
    let assignmentID: String?
    let moduleItemID: String?
    let launchType: LaunchType?

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
