//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

enum LearningLibraryObjectType: String, CaseIterable {
    case course = "COURSE"
    case page = "PAGE"
    case file = "FILE"
    case externalLink = "EXTERNAL_URL"
    case assessment = "QUIZ"
    case assignment = "ASSIGNMENT"
    case externalTool = "EXTERNAL_TOOL"
    case program = "PROGRAM"

    var name: String {
        switch self {
        case .course: String(localized: "Course")
        case .page: String(localized: "Page")
        case .file: String(localized: "File")
        case .externalLink: String(localized: "External Link")
        case .assessment: String(localized: "Assessment")
        case .assignment: String(localized: "Assignment")
        case .externalTool: String(localized: "External Tool")
        case .program: String(localized: "Program")
        }
    }

    var icon: Image {
        switch self {
        case .course: Image.huiIcons.book2
        case .page: Image.huiIcons.textSnippet
        case .file: Image.huiIcons.attachFile
        case .externalLink: Image.huiIcons.textSnippet
        case .assessment: Image.huiIcons.factCheck
        case .assignment: Image.huiIcons.editDocumentAssignment
        case .externalTool: Image.huiIcons.noteAlt
        case .program: Image.huiIcons.book5
        }
    }

    var style: HorizonUI.StatusChip.Style {
        switch self {
        case .course: .custom(
            foregroundColor: .huiColors.surface.institution,
            backgroundColor: .huiColors.surface.institution.opacity(0.1)
        )
        case .page: .sky
        case .file: .custom(
            foregroundColor: .huiColors.primitives.sea90,
            backgroundColor: .huiColors.primitives.sea12
        )
        case .externalLink: .custom(
            foregroundColor: .huiColors.primitives.copper90,
            backgroundColor: .huiColors.primitives.copper12
        )
        case .assessment: .custom(
            foregroundColor: .huiColors.primitives.forest90,
            backgroundColor: .huiColors.primitives.forest12
        )
        case .assignment: .plum
        case .externalTool: .honey
        case .program: .violet
        }
    }

    static var options: [OptionModel] {
        var options: [OptionModel] = [firstOption]
        options.append(contentsOf: LearningLibraryObjectType.allCases.map { .init(id: $0.rawValue, name: $0.name)})
        return options
    }

    static var firstOption: OptionModel {
        OptionModel(id: "-1", name: String(localized: "All item types"))
    }
}
