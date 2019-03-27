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
    let moduleID: ID
    /// The position of this item in the module (1-based)
    let position: Int
    let title: String
    /// 0-based indent level; module items may be indented to show a hierarchy
    let indent: Int
    let content: ModuleItemType
    let htmlURL: URL
    /// (Optional) link to the Canvas API object, if applicable
    let url: URL?
    /// Only present if the caller has permission to view unpublished items
    let published: Bool?

    public enum CodingKeys: String, CodingKey {
        case id
        case moduleID = "module_id"
        case position
        case title
        case indent
        case htmlURL = "html_url"
        case url
        case published
        case content
        case content_id
        case type
        case external_url
        case page_url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID.self, forKey: .id)
        moduleID = try container.decode(ID.self, forKey: .moduleID)
        position = try container.decode(Int.self, forKey: .position)
        title = try container.decode(String.self, forKey: .title)
        indent = try container.decode(Int.self, forKey: .indent)
        htmlURL = try container.decode(URL.self, forKey: .htmlURL)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        published = try container.decodeIfPresent(Bool.self, forKey: .published)
        let type = try container.decode(APIModuleItemType.self, forKey: .type)
        switch type {
        case .file:
            let id = try container.decode(ID.self, forKey: .content_id)
            content = .file(id.value)
        case .page:
            let slug = try container.decode(String.self, forKey: .page_url)
            content = .page(slug)
        case .discussion:
            let id = try container.decode(ID.self, forKey: .content_id)
            content = .discussion(id.value)
        case .assignment:
            let id = try container.decode(ID.self, forKey: .content_id)
            content = .assignment(id.value)
        case .quiz:
            let id = try container.decode(ID.self, forKey: .content_id)
            content = .quiz(id.value)
        case .subHeader:
            content = .subHeader
        case .externalURL:
            let url = try container.decode(URL.self, forKey: .external_url)
            content = .externalURL(url)
        case .externalTool:
            let id = try container.decode(ID.self, forKey: .content_id)
            let url = try container.decode(URL.self, forKey: .external_url)
            content = .externalTool(id.value, url)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(moduleID, forKey: .moduleID)
        try container.encode(position, forKey: .position)
        try container.encode(title, forKey: .title)
        try container.encode(indent, forKey: .indent)
        try container.encode(htmlURL, forKey: .htmlURL)
        try container.encode(url, forKey: .url)
        try container.encode(published, forKey: .published)
        switch content {
        case .file(let id):
            try container.encode(id, forKey: .content_id)
            try container.encode(APIModuleItemType.file, forKey: .type)
        case .page(let slug):
            try container.encode(slug, forKey: .page_url)
            try container.encode(APIModuleItemType.page, forKey: .type)
        case .discussion(let id):
            try container.encode(id, forKey: .content_id)
            try container.encode(APIModuleItemType.discussion, forKey: .type)
        case .assignment(let id):
            try container.encode(id, forKey: .content_id)
            try container.encode(APIModuleItemType.assignment, forKey: .type)
        case .quiz(let id):
            try container.encode(id, forKey: .content_id)
            try container.encode(APIModuleItemType.quiz, forKey: .type)
        case .subHeader:
            try container.encode(APIModuleItemType.subHeader, forKey: .type)
        case .externalURL(let url):
            try container.encode(url, forKey: .external_url)
            try container.encode(APIModuleItemType.externalURL, forKey: .type)
        case .externalTool(let id, let url):
            try container.encode(id, forKey: .content_id)
            try container.encode(url, forKey: .external_url)
            try container.encode(APIModuleItemType.externalTool, forKey: .type)
        }
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
