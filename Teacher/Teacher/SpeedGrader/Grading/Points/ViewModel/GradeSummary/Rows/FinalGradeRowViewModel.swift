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
import SwiftUI

struct FinalGradeRowViewModel: Equatable {
    let gradeText: String
    let a11yGradeText: String
    let suffixText: String
    let a11ySuffixText: String?
    let shouldShowNotPostedIcon: Bool

    enum SuffixType {
        case none
        case maxGradeWithUnit(String, String)
        case percentage
    }

    init(gradeText: String?, a11yGradeText: String?, suffixType: SuffixType, isGradedButNotPosted: Bool) {
        self.gradeText = gradeText ?? GradeFormatter.BlankPlaceholder.oneDash.stringValue
        self.a11yGradeText = a11yGradeText ?? String(localized: "None", bundle: .teacher)

        switch suffixType {
        case .none:
            self.suffixText = ""
            self.a11ySuffixText = nil
        case .maxGradeWithUnit(let suffix, let a11ySuffix):
            self.suffixText = "   / \(suffix)"
            self.a11ySuffixText = String(localized: "out of \(a11ySuffix)", bundle: .teacher, comment: "Example: 'out of 10 points'")
        case .percentage:
            self.suffixText = "   %"
            self.a11ySuffixText = "%"
        }

        self.shouldShowNotPostedIcon = isGradedButNotPosted
    }
}
