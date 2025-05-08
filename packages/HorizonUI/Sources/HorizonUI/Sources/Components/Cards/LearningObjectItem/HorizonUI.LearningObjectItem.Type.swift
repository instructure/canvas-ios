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

public extension HorizonUI.LearningObjectItem {

    enum ItemType: String {
        case page = "Page"
        case assignment = "Assignment"
        case externalLink = "ModuleItem"
        case file = "File"
        case externalTool = "ExternalTool"
        case assessment = "Quiz"

        var icon: Image {
            switch self {
            case .page: return .huiIcons.textSnippet
            case .assignment: return .huiIcons.editDocumentAssignment
            case .externalLink: return .huiIcons.link
            case .file: return .huiIcons.attachFile
            case .externalTool: return .huiIcons.noteAlt
            case .assessment: return .huiIcons.factCheck
            }
        }

        var name: String {
            switch self {
            case .page: return String(localized: "Page")
            case .assignment: return String(localized: "Assignment")
            case .externalLink: return String(localized: "External Link")
            case .file: return String(localized: "File")
            case .externalTool: return String(localized: "External Tool")
            case .assessment: return String(localized: "Assessment")
            }
        }

        var status: String {
            switch self {
            case .page: return String(localized: "Viewed")
            case .assignment, .assessment: return String(localized: "Submitted")
            default: return String(localized: "Viewed")
            }
        }
    }
}
