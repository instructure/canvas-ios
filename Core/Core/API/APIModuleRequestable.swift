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

// https://canvas.instructure.com/doc/api/modules.html#method.context_modules_api.index
public struct GetModulesRequest: APIRequestable {
    public typealias Response = [APIModule]
    public enum Include: String {
        case content_details, items
    }

    public let courseID: String
    public let include: [Include]
    public let perPage: Int?

    public init(courseID: String, include: [Include] = [], perPage: Int? = nil) {
        self.courseID = courseID
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
        ]
        if let perPage = perPage {
            query.append(.perPage(perPage))
        }
        return query
    }
}

public struct GetModuleItemsRequest: APIRequestable {
    public typealias Response = [APIModuleItem]
    public enum Include: String {
        case content_details, mastery_paths
    }

    public let courseID: String
    public let moduleID: String
    public let include: [Include]
    public let perPage: Int?

    public init(courseID: String, moduleID: String, include: [Include], perPage: Int? = nil) {
        self.courseID = courseID
        self.moduleID = moduleID
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
        ]
        if let perPage = perPage {
            query.append(.perPage(perPage))
        }
        return query
    }
}

public struct GetModuleItemRequest: APIRequestable {
    public typealias Response = APIModuleItem

    public enum Include: String {
        case content_details
    }

    public let courseID: String
    public let moduleID: String
    public let itemID: String
    public let include: [Include]

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(itemID)"
    }

    public var query: [APIQueryItem] {
        return [
            .include(include.map { $0.rawValue }),
        ]
    }
}

public struct GetModuleItemSequenceRequest: APIRequestable {
    public typealias Response = APIModuleItemSequence

    public enum AssetType: String {
        case moduleItem = "ModuleItem"
        case file = "File"
        case page = "Page"
        case discussion = "Discussion"
        case assignment = "Assignment"
        case quiz = "Quiz"
        case externalTool = "ExternalTool"
    }

    public let courseID: String
    public let assetType: AssetType
    public let assetID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/module_item_sequence"
    }

    public var query: [APIQueryItem] {
        return [
            .value("asset_type", assetType.rawValue),
            .value("asset_id", assetID),
        ]
    }
}

// https://canvas.instructure.com/doc/api/modules.html#method.context_module_items_api.mark_item_read
public struct PostMarkModuleItemRead: APIRequestable {
    public typealias Response = APINoContent

    public let courseID: String
    public let moduleID: String
    public let moduleItemID: String
    public let method: APIMethod = .post
    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(moduleItemID)/mark_read"
    }
}

// https://canvas.instructure.com/doc/api/modules.html#method.context_module_items_api.mark_as_done
public struct PutMarkModuleItemDone: APIRequestable {
    public typealias Response = APINoContent

    public let courseID: String
    public let moduleID: String
    public let moduleItemID: String
    public let done: Bool
    public var method: APIMethod { done ? .put : .delete }
    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(moduleItemID)/done"
    }
}
