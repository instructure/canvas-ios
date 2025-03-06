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

// https://canvas.instructure.com/doc/api/modules.html#Module
public struct APIModule: Codable, Equatable {
    public let id: ID
    public let name: String
    /// the position of this module in the course (1-based)
    public let position: Int
    public let published: Bool?
    public let prerequisite_module_ids: [String]
    public let require_sequential_progress: Bool?
    public let state: ModuleState?
    public var items: [APIModuleItem]?
    public var unlock_at: Date?
    public var estimated_duration: String?
}

// https://canvas.instructure.com/doc/api/modules.html#ModuleItem
public struct APIModuleItem: Codable, Equatable {
    public struct ContentDetails: Codable, Equatable {
        public let due_at: Date?
        public let points_possible: Double?
        public let locked_for_user: Bool?
        public let lock_explanation: String?
        public let hidden: Bool?
        public let unlock_at: Date?
        public let lock_at: Date?
        public let page_url: String?
    }

    public let id: ID
    public let module_id: ID
    /// The position of this item in the module (1-based)
    public let position: Int
    public let title: String
    /// 0-based indent level; module items may be indented to show a hierarchy
    public let indent: Int
    public let content: ModuleItemType?
    /// link to the item in Canvas
    /// eg: "https://canvas.example.edu/courses/222/modules/items/768"
    public let html_url: URL?
    /// (Optional) link to the Canvas API object, if applicable
    /// eg: "https://canvas.example.edu/api/v1/courses/222/assignments/987"
    public let url: URL?
    /// (Only for 'Page' type) unique locator for the linked wiki page
    public let pageId: String?
    /// Only present if the caller has permission to view unpublished items
    public let published: Bool?
    /// Indicates whether the item is allowed to be unpublished. This could be false e.g. when related assignment already has submissions.
    public let unpublishable: Bool?
    public let content_details: ContentDetails? // include[]=content_details not available in sequence call
    public var completion_requirement: CompletionRequirement? // not available in sequence call
    public let mastery_paths: APIMasteryPath? // include[]=mastery_paths
    public let quiz_lti: Bool?
    public var estimated_duration: String?

    public init(
        id: ID,
        module_id: ID,
        position: Int,
        title: String,
        indent: Int,
        content: ModuleItemType?,
        html_url: URL?,
        url: URL?,
        pageId: String?,
        published: Bool?,
        unpublishable: Bool?,
        content_details: ContentDetails?,
        completion_requirement: CompletionRequirement?,
        mastery_paths: APIMasteryPath?,
        quiz_lti: Bool?
    ) {
        self.id = id
        self.module_id = module_id
        self.position = position
        self.title = title
        self.indent = indent
        self.content = content
        self.html_url = html_url
        self.url = url
        self.pageId = pageId
        self.published = published
        self.unpublishable = unpublishable
        self.content_details = content_details
        self.completion_requirement = completion_requirement
        self.mastery_paths = mastery_paths
        self.quiz_lti = quiz_lti
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case module_id
        case position
        case title
        case indent
        case html_url
        case url
        case page_url
        case published
        case unpublishable
        case content
        case content_details
        case completion_requirement
        case mastery_paths
        case quiz_lti
        case estimated_duration
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        module_id = try container.decode(ID.self, forKey: .module_id)
        position = try container.decode(Int.self, forKey: .position)
        title = try container.decode(String.self, forKey: .title)
        indent = try container.decodeIfPresent(Int.self, forKey: .indent) ?? 0
        html_url = try container.decodeIfPresent(URL.self, forKey: .html_url)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        pageId = try container.decodeIfPresent(String.self, forKey: .page_url)
        published = try container.decodeIfPresent(Bool.self, forKey: .published)
        unpublishable = try container.decodeIfPresent(Bool.self, forKey: .unpublishable)
        content = try ModuleItemType?(from: decoder)
        content_details = try container.decodeIfPresent(ContentDetails.self, forKey: .content_details)
        completion_requirement = try container.decodeIfPresent(CompletionRequirement.self, forKey: .completion_requirement)
        mastery_paths = try container.decodeIfPresent(APIMasteryPath.self, forKey: .mastery_paths)
        quiz_lti = try container.decodeIfPresent(Bool.self, forKey: .quiz_lti)
        estimated_duration = try container.decodeIfPresent(String.self, forKey: .estimated_duration)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(module_id, forKey: .module_id)
        try container.encode(position, forKey: .position)
        try container.encode(title, forKey: .title)
        try container.encode(indent, forKey: .indent)
        try container.encode(html_url, forKey: .html_url)
        try container.encode(url, forKey: .url)
        try container.encode(pageId, forKey: .page_url)
        try container.encode(published, forKey: .published)
        try container.encodeIfPresent(content_details, forKey: .content_details)
        try container.encode(completion_requirement, forKey: .completion_requirement)
        try container.encodeIfPresent(mastery_paths, forKey: .mastery_paths)
        try container.encodeIfPresent(quiz_lti, forKey: .quiz_lti)
        try container.encodeIfPresent(estimated_duration, forKey: .estimated_duration)
        try content?.encode(to: encoder)
    }
}

enum APIModuleItemType: String, Codable {
    case file = "File"
    case page = "Page"
    case discussion = "Discussion"
    case assignment = "Assignment"
    case quiz = "Quiz"
    case subHeader = "SubHeader"
    case externalURL = "ExternalUrl"
    case externalTool = "ExternalTool"
}

// https://canvas.instructure.com/doc/api/modules.html#ModuleItemSequence
public struct APIModuleItemSequence: Codable, Equatable {
    public struct Node: Codable, Equatable {
        let prev: APIModuleItem?
        let current: APIModuleItem?
        let next: APIModuleItem?
    }

    public let items: [Node]
    public let modules: [APIModule]
}

public struct APIMasteryPath: Codable, Equatable {
    public struct AssignmentSet: Codable, Equatable {
        public let id: ID
        public let position: Int?
        public let assignment_set_associations: [Assignment]?
    }

    public struct Assignment: Codable, Equatable {
        public let position: Int?
        public let model: APIAssignment
    }

    public let locked: Bool
    public let assignment_sets: [AssignmentSet]
    public let selected_set_id: ID?
}

#if DEBUG
extension APIModule {
    public static func make(
        id: ID = "1",
        name: String = "Module 1",
        position: Int = 1,
        published: Bool = true,
        prerequisite_module_ids: [String] = [],
        require_sequential_progress: Bool = false,
        state: ModuleState? = nil,
        items: [APIModuleItem]? = nil,
        unlock_at: Date? = nil
    ) -> APIModule {
        return APIModule(
            id: id,
            name: name,
            position: position,
            published: published,
            prerequisite_module_ids: prerequisite_module_ids,
            require_sequential_progress: require_sequential_progress,
            state: state,
            items: items,
            unlock_at: unlock_at
        )
    }
}

extension APIModuleItem {
    public static func make(
        id: ID = "1",
        module_id: ID = "1",
        position: Int = 1,
        title: String = "Module Item 1",
        indent: Int = 0,
        content: ModuleItemType = .assignment("1"),
        html_url: URL? = URL(string: "https://canvas.example.edu/courses/222/modules/items/768"),
        url: URL? = URL(string: "https://canvas.example.edu/api/v1/courses/222/assignments/987"),
        pageId: String? = nil,
        published: Bool? = nil,
        unpublishable: Bool? = nil,
        content_details: ContentDetails? = nil,
        completion_requirement: CompletionRequirement? = nil,
        mastery_paths: APIMasteryPath? = nil,
        quiz_lti: Bool? = nil
    ) -> APIModuleItem {
        return APIModuleItem(
            id: id,
            module_id: module_id,
            position: position,
            title: title,
            indent: indent,
            content: content,
            html_url: html_url,
            url: url,
            pageId: pageId,
            published: published,
            unpublishable: unpublishable,
            content_details: content_details,
            completion_requirement: completion_requirement,
            mastery_paths: mastery_paths,
            quiz_lti: quiz_lti
        )
    }
}

extension APIModuleItem.ContentDetails {
    public static func make(
        due_at: Date? = nil,
        points_possible: Double? = nil,
        locked_for_user: Bool? = nil,
        lock_explanation: String? = nil,
        hidden: Bool? = nil,
        unlock_at: Date? = nil,
        lock_at: Date? = nil,
        page_url: String? = nil
    ) -> APIModuleItem.ContentDetails {
        return APIModuleItem.ContentDetails(
            due_at: due_at,
            points_possible: points_possible,
            locked_for_user: locked_for_user,
            lock_explanation: lock_explanation,
            hidden: hidden,
            unlock_at: unlock_at,
            lock_at: lock_at,
            page_url: page_url
        )
    }
}

extension APIModuleItemSequence.Node {
    public static func make(
        prev: APIModuleItem? = nil,
        current: APIModuleItem? = nil,
        next: APIModuleItem? = nil
    ) -> Self {
        return .init(prev: prev, current: current, next: next)
    }
}

extension APIModuleItemSequence {
    public static func make(
        items: [Node] = [.make()],
        modules: [APIModule] = [.make()]
    ) -> Self {
        return .init(items: items, modules: modules)
    }
}

extension APIMasteryPath {
    public static func make(
        locked: Bool = false,
        assignment_sets: [AssignmentSet] = [],
        selected_set_id: ID? = nil
    ) -> Self {
        return .init(locked: locked, assignment_sets: assignment_sets, selected_set_id: selected_set_id)
    }
}

extension APIMasteryPath.AssignmentSet {
    public static func make(
        id: ID = "1",
        position: Int = 0,
        assignments: [APIMasteryPath.Assignment] = [.make()]
    ) -> Self {
        return .init(id: id, position: position, assignment_set_associations: assignments)
    }
}

extension APIMasteryPath.Assignment {
    public static func make(
        position: Int = 0,
        model: APIAssignment = .make()
    ) -> Self {
        return .init(position: position, model: model)
    }
}
#endif

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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue })
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue })
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(itemID)"
    }

    public var query: [APIQueryItem] {
        return [
            .include(include.map { $0.rawValue })
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/module_item_sequence"
    }

    public var query: [APIQueryItem] {
        return [
            .value("asset_type", assetType.rawValue),
            .value("asset_id", assetID)
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
        let context = Context(.course, id: courseID)
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(moduleItemID)/done"
    }
}

// https://canvas.instructure.com/doc/api/modules.html#method.context_module_items_api.select_mastery_path
public struct PostSelectMasteryPath: APIRequestable {
    public typealias Response = APINoContent

    public let courseID: String
    public let moduleID: String
    public let moduleItemID: String
    public let assignmentSetID: String

    public let method = APIMethod.post
    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules/\(moduleID)/items/\(moduleItemID)/select_mastery_path"
    }
    public var query: [APIQueryItem] {
        return [.value("assignment_set_id", assignmentSetID)]
    }
}
