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

import UIKit

public enum ModuleItemType: Equatable, Codable {
    case file(String)
    case discussion(String)
    case assignment(String)
    case quiz(String)
    case externalURL(URL)
    case externalTool(String, URL)
    case page(String)
    case subHeader

    public enum CodingKeys: CodingKey {
        case type
        case content_id
        case page_url
        case external_url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(APIModuleItemType.self, forKey: .type)
        switch type {
        case .file:
            let id = try container.decode(ID.self, forKey: .content_id)
            self = .file(id.value)
        case .page:
            let slug = try container.decode(String.self, forKey: .page_url)
            self = .page(slug)
        case .discussion:
            let id = try container.decode(ID.self, forKey: .content_id)
            self = .discussion(id.value)
        case .assignment:
            let id = try container.decode(ID.self, forKey: .content_id)
            self = .assignment(id.value)
        case .quiz:
            let id = try container.decode(ID.self, forKey: .content_id)
            self = .quiz(id.value)
        case .subHeader:
            self = .subHeader
        case .externalURL:
            let url = try container.decode(APIURL.self, forKey: .external_url)
            self = .externalURL(url.rawValue)
        case .externalTool:
            let id = try container.decode(ID.self, forKey: .content_id)
            let url = try container.decode(APIURL.self, forKey: .external_url)
            self = .externalTool(id.value, url.rawValue)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
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

    public var icon: UIImage? {
        switch self {
        case .subHeader:
            return nil
        case .file:
            return .folderLine
        case .page:
            return .documentLine
        case .discussion:
            return .discussionLine
        case .assignment:
            return .assignmentLine
        case .quiz:
            return .quizLine
        case .externalURL:
            return .linkLine
        case .externalTool:
            return .ltiLine
        }
    }

    public var label: String? {
        switch self {
        case .subHeader:
            return nil
        case .file:
            return String(localized: "file", bundle: .core)
        case .page:
            return String(localized: "page", bundle: .core)
        case .discussion:
            return String(localized: "discussion", bundle: .core)
        case .assignment:
            return String(localized: "assignment", bundle: .core)
        case .quiz:
            return String(localized: "quiz", bundle: .core)
        case .externalURL:
            return String(localized: "external URL", bundle: .core)
        case .externalTool:
            return String(localized: "external tool", bundle: .core)
        }
    }

    var assetType: GetModuleItemSequenceRequest.AssetType {
        switch self {
        case .file: return .file
        case .discussion: return .discussion
        case .assignment: return .assignment
        case .quiz: return .quiz
        case .externalURL: return .moduleItem
        case .externalTool: return .externalTool
        case .page: return .page
        case .subHeader: return .moduleItem
        }
    }
}

public extension Optional where Wrapped == ModuleItemType {

    var isFile: Bool {
        if case .file = self {
            return true
        }
        return false
    }
    var fileId: String? {
        if case .file(let fileId) = self {
            return fileId
        }
        return nil
    }
}
