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

import Core
import Foundation

/// This enum unifies user defined and canvas defined statuses into a single object.
enum GradeStatus: Equatable, Identifiable, OptionItemIdentifiable {
    /// The assignment was submitted late and if a late penalty is configured it will be deducted from the given score.
    case late
    /// The assignment was not submitted by the student and is considered missing.
    case missing
    /// The user is excused from the assignment, so no score will be given.
    case excused
    case extended
    /// There is no status assigned for the assignment.
    case none
    /// Any canvas statuses returned by the API that are not one of the known defaults.
    case unknownDefault(String)
    /// User entered custom statuses.
    case userDefined(id: String, name: String)

    var id: String {
        switch self {
        case .late: return "late"
        case .missing: return "missing"
        case .excused: return "excused"
        case .extended: return "extended"
        case .none: return "none"
        case .unknownDefault(let value): return value
        case .userDefined(let id, _): return id
        }
    }

    var name: String {
        switch self {
        case .late: return String(localized: "Late")
        case .missing: return String(localized: "Missing")
        case .excused: return String(localized: "Excused")
        case .extended: return String(localized: "Extended")
        case .none: return String(localized: "None")
        case .unknownDefault(let value): return value.capitalized
        // The name is entered by the teacher, so we can't localize it
        // just use what we received from the API.
        // It's up to the teacher to use an appropriate name
        // that is understandable in the context of their course.
        case .userDefined(_, let name): return name
        }
    }

    /// User defined and default statuses need to be uploaded to different fields on the API
    /// so we need to distinguish between the two types to know which goes where.
    var isUserDefined: Bool {
        if case .userDefined = self { return true }
        return false
    }

    init(defaultStatus: String) {
        switch defaultStatus {
        case "late": self = .late
        case "missing": self = .missing
        case "excused": self = .excused
        case "extended": self = .extended
        case "none": self = .none
        default: self = .unknownDefault(defaultStatus)
        }
    }

    init(userDefinedName: String, id: String) {
        self = .userDefined(id: id, name: userDefinedName)
    }
}
