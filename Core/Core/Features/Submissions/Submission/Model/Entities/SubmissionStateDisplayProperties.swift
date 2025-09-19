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

/// This is merely used to properly describe the state of submission in certain contexts.
/// It is not strictly matching `SubmissionStatus` in all cases. And it is not
/// meant to replace status cases, or be used in all related areas of the apps.
/// i.e. use with caution.
public enum SubmissionStateDisplayProperties: Equatable {
    case usingStatus(SubmissionStatusOld)
    case onPaper
    case noSubmission
    case graded

    public var text: String {
        switch self {
        case .usingStatus(let status):
            return status.text
        case .onPaper:
            return String(localized: "On Paper", bundle: .core)
        case .noSubmission:
            return String(localized: "No Submission", bundle: .core)
        case .graded:
            return String(localized: "Graded", bundle: .core)
        }
    }

    public var color: UIColor {
        switch self {
        case .usingStatus(let status):
            return status.color
        case .onPaper, .noSubmission:
            return .textDark
        case .graded:
            return .textSuccess
        }
    }

    public var icon: UIImage {
        switch self {
        case .usingStatus(let status):
            return status.icon
        case .onPaper, .noSubmission:
            return .noSolid
        case .graded:
            return .completeSolid
        }
    }
}
