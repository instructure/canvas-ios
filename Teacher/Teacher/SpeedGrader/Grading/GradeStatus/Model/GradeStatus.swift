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

import Foundation

/// This structure unifies user defined and canvas defined statuses into a single object.
struct GradeStatus: Identifiable, Equatable {
    let id: String
    let name: String
    /// Custom and default statuses need to be uploaded to different fields on the API
    /// so we need to distinguish between the two types to know which goes where.
    let isCustom: Bool

    /// This initializer can be used to create a status from a custom status entered by the teacher on canvas web.
    init(custom: APIGradeStatuses.CustomGradeStatus) {
        self.id = custom.id
        // The name is entered by the teacher, so we can't localize it.
        // It's up to the teacher to use an appropriate name
        // that is understandable in the context of their course.
        self.name = custom.name
        self.isCustom = true
    }

    /// This initializer can be used to create a grade status that is defined by canvas on a global level.
    init(defaultName: String) {
        self.id = defaultName
        self.name = defaultName.localizedGradeStatusName
        self.isCustom = false
    }
}

extension String {

    internal var localizedGradeStatusName: String {
        switch self {
        case "late": String(localized: "Late", bundle: .teacher)
        case "missing": String(localized: "Missing", bundle: .teacher)
        case "excused": String(localized: "Excused", bundle: .teacher)
        case "extended": String(localized: "Extended", bundle: .teacher)
        case "none": String(localized: "None", bundle: .teacher)
        default: capitalized
        }
    }
}
