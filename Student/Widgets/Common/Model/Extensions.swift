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

import WidgetKit
import Core
import SwiftUI

extension TimeInterval {
    #if DEBUG
    static let widgetRefresh: TimeInterval = 120
    static let widgetRecover: TimeInterval = 10
    static let gradeListWidgetRefresh: TimeInterval = 120
    #else
    static let widgetRefresh: TimeInterval = 7200 // 2 hours
    static let widgetRecover: TimeInterval = 900 // 15 minutes
    static let gradeListWidgetRefresh: TimeInterval = 1800 // 30 minutes
    #endif
}

extension WidgetFamily {
    var shownTodoItemsMaximumCount: Int {
        switch self {
        case .systemSmall: 1
        case .systemMedium: 2
        case .systemLarge: 5
        default: 5
        }
    }
}

extension Color {
    static var brandPrimary: Color {
        Color(Brand.shared.primary)
    }
}

extension ShapeStyle where Self == Color {
    static var brandPrimary: Color {
        .brandPrimary
    }
}

extension String {
    func gradeListStyled() -> AttributedString {
        var attributed = AttributedString(self)

        if self == String(localized: "No Grades") {
            attributed.foregroundColor = Color.textDark
            attributed.font = Font.regular14
            return attributed
        }

        let spaceCorrected = components(separatedBy: "/")
            .map({ $0.trimmed() })
            .joined(separator: " / ")

        attributed = AttributedString(spaceCorrected)

        if let range = attributed.range(of: "/") {
            // Apply secondary color to everything from "/" to the end
            let mainRange = attributed.startIndex ..< range.lowerBound
            let secondaryRange = range.lowerBound ..< attributed.endIndex

            attributed[mainRange].foregroundColor = Color.textDarkest
            attributed[mainRange].font = Font.semibold14

            attributed[secondaryRange].foregroundColor = Color.textDark
            attributed[secondaryRange].font = Font.regular14
        } else {

            attributed.foregroundColor = Color.textDarkest
            attributed.font = Font.semibold14
        }

        return attributed
    }
}

extension View {
    func defaultWidgetContainer() -> some View {
        containerBackground(for: .widget) { Color.backgroundLightest }
    }
}
