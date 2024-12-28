//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SwiftUI

public extension HorizonUI.ModuleItemCard {

    enum ItemType: String {
        case page = "Page"
        case assignment = "Assignment"
        case externalLink = "ModuleItem"
        case file = "File"
        case externalTool = "ExternalTool"
        // TODO:  Need to check is the ok or not ???
        case assessment = "Quiz"
        // TODO: discussion was missed, i add it but need to check the icon
        case discussion = "Discussion"

        var icon: Image {
            switch self {
            case .page: return .huiIcons.textSnippet
            case .assignment: return .huiIcons.editDocumentAssignment
            case .externalLink: return .huiIcons.link
            case .file: return .huiIcons.attachFile
            case .externalTool: return .huiIcons.noteAlt
            case .assessment: return .huiIcons.factCheck
            case .discussion: return .huiIcons.chat
            }
        }

        var name: String {
            switch self {
            case .page: return "Page"
            case .assignment: return "Assignment"
            case .externalLink: return "External Link"
            case .file: return "File"
            case .externalTool: return "External Tool"
            case .assessment: return "Assessment"
            case .discussion: return "Discussion"
            }
        }
    }
}
