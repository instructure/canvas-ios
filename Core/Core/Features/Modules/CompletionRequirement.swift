//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct CompletionRequirement: Codable, Equatable {
    public let type: CompletionRequirementType
    public var completed: Bool?
    public let min_score: Double?

    public var description: String? {
        switch type {
        case .must_view:
            return completed != true
                ? String(localized: "View", bundle: .core)
                : String(localized: "Viewed", bundle: .core)
        case .must_submit:
            return completed != true
                ? String(localized: "Submit", bundle: .core)
                : String(localized: "Submitted", bundle: .core)
        case .must_contribute:
            return completed != true
                ? String(localized: "Contribute", bundle: .core)
                : String(localized: "Contributed", bundle: .core)
        case .min_score:
            guard let score = NSNumber(value: min_score) else { return nil }
            let template = completed != true
                ? String(localized: "Score at least %@", bundle: .core)
                : String(localized: "Scored at least %@", bundle: .core)
            return String.localizedStringWithFormat(template, score)
        case .must_mark_done:
            return completed != true
                ? String(localized: "Mark done", bundle: .core)
                : String(localized: "Marked done", bundle: .core)
        }
    }
}

public enum CompletionRequirementType: String, Codable {
    case min_score, must_view, must_submit, must_contribute, must_mark_done
}

#if DEBUG
extension CompletionRequirement {
    public static func make(
        type: CompletionRequirementType = .must_view,
        completed: Bool? = false,
        min_score: Double? = nil
    ) -> CompletionRequirement {
        return CompletionRequirement(type: type, completed: completed, min_score: min_score)
    }
}

#endif
