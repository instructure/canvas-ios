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

struct GradeStatus: Identifiable, Equatable {
    let id: String
    let name: String
    let isCustom: Bool

    init(custom: APIGradeStatuses.CustomGradeStatus) {
        self.id = custom.id
        self.name = custom.name
        self.isCustom = true
    }

    init(defaultName: String) {
        self.id = defaultName
        self.name = defaultName.localizedGradeStatusName
        self.isCustom = false
    }
}

extension String {

    var localizedGradeStatusName: String {
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
