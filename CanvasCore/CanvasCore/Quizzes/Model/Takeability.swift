//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

enum Takeability: Equatable {
    enum NotTakeableReason: Equatable {
        case locked
        case ipFiltered
        case attemptLimitReached
        case undecided
        case other(String)
        case offline
    }

    case notTakeable(reason: NotTakeableReason)
    case take
    case resume
    case retake
    case viewResults(URL)

    var takeable: Bool {
        return self == .take || self == .resume || self == .retake
    }

    var label: String {
        switch self {
        case .notTakeable:
            return ""
        case .take:
            return NSLocalizedString("Take Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "Button for taking the quiz")
        case .resume:
            return NSLocalizedString("Resume Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "button for resuming a quiz")
        case .retake:
            return NSLocalizedString("Retake Quiz", tableName: "Localizable", bundle: .core, value: "", comment: "button for retaking quiz")
        case .viewResults:
            return NSLocalizedString("View Results", tableName: "Localizable", bundle: .core, value: "", comment: "button for viewing quiz results")
        }
    }
}
