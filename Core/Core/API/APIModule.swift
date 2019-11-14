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
    public var items: [APIModuleItem]?
}

// https://canvas.instructure.com/doc/api/modules.html#ModuleItem
public struct APIModuleItem: Codable, Equatable {
    public struct ContentDetails: Codable, Equatable {
        public let due_at: Date?
    }

    public let id: ID
    public let module_id: ID
    /// The position of this item in the module (1-based)
    public let position: Int
    public let title: String
    /// 0-based indent level; module items may be indented to show a hierarchy
    public let indent: Int
    public let content: ModuleItemType
    /// link to the item in Canvas
    /// eg: "https://canvas.example.edu/courses/222/modules/items/768"
    public let html_url: URL?
    /// (Optional) link to the Canvas API object, if applicable
    /// eg: "https://canvas.example.edu/api/v1/courses/222/assignments/987"
    public let url: URL?
    /// Only present if the caller has permission to view unpublished items
    public let published: Bool?
    public let content_details: ContentDetails // include[]=content_details

    public init(
        id: ID,
        module_id: ID,
        position: Int,
        title: String,
        indent: Int,
        content: ModuleItemType,
        html_url: URL?,
        url: URL?,
        published: Bool?,
        content_details: ContentDetails
    ) {
        self.id = id
        self.module_id = module_id
        self.position = position
        self.title = title
        self.indent = indent
        self.content = content
        self.html_url = html_url
        self.url = url
        self.published = published
        self.content_details = content_details
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case module_id
        case position
        case title
        case indent
        case html_url
        case url
        case published
        case content
        case content_details
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        module_id = try container.decode(ID.self, forKey: .module_id)
        position = try container.decode(Int.self, forKey: .position)
        title = try container.decode(String.self, forKey: .title)
        indent = try container.decode(Int.self, forKey: .indent)
        html_url = try container.decodeIfPresent(URL.self, forKey: .html_url)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        published = try container.decodeIfPresent(Bool.self, forKey: .published)
        content = try ModuleItemType(from: decoder)
        content_details = try container.decode(ContentDetails.self, forKey: .content_details)
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
        try container.encode(published, forKey: .published)
        try container.encode(content_details, forKey: .content_details)
        try content.encode(to: encoder)
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
