//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import HorizonUI

enum LearningObjectType: String {
    case externalUrl = "ExternalUrl"
    case page = "Page"
    case assignment = "Assignment"
    case file = "File"
    case externalTool = "ExternalTool"
    case assessment = "Quiz"
    case discussion = "Discussion"

    func getIcon(isAssessment: Bool) -> Image {
        if isAssessment {
            return .huiIcons.factCheck
        } else {
            switch self {
            case .page: return .huiIcons.textSnippet
            case .assignment: return .huiIcons.editDocumentAssignment
            case .externalUrl: return .huiIcons.link
            case .file: return .huiIcons.attachFile
            case .externalTool: return .huiIcons.noteAlt
            case .assessment: return .huiIcons.factCheck
            case .discussion: return .huiIcons.forumDiscussion
            }
        }
    }
}
