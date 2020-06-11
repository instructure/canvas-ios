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
            let url = try container.decode(URL.self, forKey: .external_url)
            self = .externalURL(url)
        case .externalTool:
            let id = try container.decode(ID.self, forKey: .content_id)
            let url = try container.decode(URL.self, forKey: .external_url)
            self = .externalTool(id.value, url)
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
            return .icon(.folder)
        case .page:
            return .icon(.document)
        case .discussion:
            return .icon(.discussion)
        case .assignment:
            return .icon(.assignment)
        case .quiz:
            return .icon(.quiz)
        case .externalURL:
            return .icon(.link)
        case .externalTool:
            return .icon(.lti)
        }
    }

    public var label: String? {
        switch self {
        case .subHeader:
            return nil
        case .file:
            return NSLocalizedString("file", bundle: .core, comment: "")
        case .page:
            return NSLocalizedString("page", bundle: .core, comment: "")
        case .discussion:
            return NSLocalizedString("discussion", bundle: .core, comment: "")
        case .assignment:
            return NSLocalizedString("assignment", bundle: .core, comment: "")
        case .quiz:
            return NSLocalizedString("quiz", bundle: .core, comment: "")
        case .externalURL:
            return NSLocalizedString("external URL", bundle: .core, comment: "")
        case .externalTool:
            return NSLocalizedString("external tool", bundle: .core, comment: "")
        }
    }
}
