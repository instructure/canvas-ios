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
import Core

extension String {

    func styledAsGrade() -> AttributedString {

        if isLocalizedNA {
            let noGradesText = String(localized: "No Grades")
            var attributed = AttributedString(noGradesText)
            attributed.foregroundColor = Color.textDark
            attributed.font = Font.scaledRestrictly(.regular22)
            return attributed
        }

        let spaceCorrected = components(separatedBy: "/")
            .map({ $0.trimmed() })
            .joined(separator: " / ")

        var attributed = AttributedString(spaceCorrected)

        if let range = attributed.range(of: "/") {
            // Apply secondary color to everything from "/" to the end
            let mainRange = attributed.startIndex ..< range.lowerBound
            let secondaryRange = range.lowerBound ..< attributed.endIndex

            attributed[mainRange].foregroundColor = Color.textDarkest
            attributed[mainRange].font = Font.scaledRestrictly(.bold22)

            attributed[secondaryRange].foregroundColor = Color.textDark
            attributed[secondaryRange].font = Font.scaledRestrictly(.regular22)
        } else {

            attributed.foregroundColor = Color.textDarkest
            attributed.font = Font.scaledRestrictly(.bold22)
        }

        return attributed
    }
}
