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
import UIKit

public enum SubmissionStatusOld: Hashable {
    case late
    case missing
    case submitted
    case notSubmitted
    case graded
    case excused
    case custom(String)

    public var text: String {
        switch self {
        case .late:
            return String(localized: "Late", bundle: .core)
        case .missing:
            return String(localized: "Missing", bundle: .core)
        case .submitted:
            return String(localized: "Submitted", bundle: .core)
        case .notSubmitted:
            return String(localized: "Not Submitted", bundle: .core)
        case .excused:
            return String(localized: "Excused", bundle: .core)
        case .custom(let name):
            return name
        case .graded:
            return String(localized: "Graded", bundle: .core)
        }
    }

    public var color: UIColor {
        switch self {
        case .late:
            return .textWarning
        case .missing:
            return .textDanger
        case .submitted:
            return .textSuccess
        case .notSubmitted:
            return .textDark
        case .excused:
            return .textWarning
        case .custom:
            return .textInfo
        case .graded:
            return .textSuccess
        }
    }

    public var icon: UIImage {
        switch self {
        case .submitted:
            return .completeLine
        case .late:
            return .clockSolid
        case .missing, .notSubmitted:
            return .noSolid
        case .excused, .graded:
            return .completeSolid
        case .custom:
            return .flagLine
        }
    }

    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }
}
