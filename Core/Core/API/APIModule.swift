//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/modules.html#Module
public struct APIModule: Codable, Equatable {
    let id: ID
    let name: String
    let position: Int
    let published: Bool
    let items: [APIModuleItem]?
}

// https://canvas.instructure.com/doc/api/modules.html#ModuleItem
public struct APIModuleItem: Codable, Equatable {
    let id: ID
    let module_id: ID
    /// The position of this item in the module (1-based)
    let position: Int
    let title: String
    /// 0-based indent level; module items may be indented to show a hierarchy
    let indent: Int
    let content: ModuleItemType
    let html_url: URL
    /// (Optional) link to the Canvas API object, if applicable
    let url: URL?
    /// Only present if the caller has permission to view unpublished items
    let published: Bool?

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
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        module_id = try container.decode(ID.self, forKey: .module_id)
        position = try container.decode(Int.self, forKey: .position)
        title = try container.decode(String.self, forKey: .title)
        indent = try container.decode(Int.self, forKey: .indent)
        html_url = try container.decode(URL.self, forKey: .html_url)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        published = try container.decodeIfPresent(Bool.self, forKey: .published)
        content = try ModuleItemType(from: decoder)
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
