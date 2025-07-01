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
import SwiftUI
import Core

class GradeListModel: WidgetModel {
    override class var publicPreview: GradeListModel {
        Self.make()
    }

    let items: [GradeListItem]

    init(isLoggedIn: Bool = true, items: [GradeListItem] = []) {
        self.items = items
        super.init(isLoggedIn: isLoggedIn)
    }

    func getItems(for widgetFamily: WidgetFamily, size: DynamicTypeSize? = nil) -> [GradeListItem] {
        let isMediumFamily = widgetFamily == .systemMedium
        let maxItemCount = if let size, size.isAccessibilitySize {
            switch size {
            case .accessibility1:
                isMediumFamily ? 4 : 8
            case .accessibility2:
                isMediumFamily ? 3 : 7
            case .accessibility3:
                isMediumFamily ? 3 : 6
            default:
                isMediumFamily ? 2 : 5
            }
        } else {
            isMediumFamily ? 4 : 10
        }

        guard items.count > maxItemCount else {
            return items
        }
        let limitedItems = Array(items[0 ..< maxItemCount])
        return limitedItems.isNotEmpty ? limitedItems : []
    }
}

// MARK: - Previews

extension GradeListModel {

    static func make(count: Int? = nil) -> GradeListModel {
        let items: [GradeListItem] = [
            .make(
                courseId: "1",
                courseName: "Biology 101",
                grade: "82/100",
                color: .blue
            ),
            .make(
                courseId: "2",
                courseName: "Mathematics 904 2024/25",
                grade: "Good",
                color: .purple
            ),
            .make(
                courseId: "3",
                courseName: "English Literature 101",
                grade: "A+",
                color: .green
            ),
            .make(
                courseId: "4",
                courseName: "Greek Literature",
                grade: "Good",
                color: .cyan
            ),
            .make(
                courseId: "5",
                courseName: "Space and Stars",
                grade: "97%",
                color: .yellow
            ),
            .make(
                courseId: "6",
                courseName: "General Astrology",
                grade: "No Grades",
                color: .cyan
            ),
            .make(
                courseId: "7",
                courseName: "Greek Literature",
                grade: "Good",
                color: .cyan
            ),
            .make(
                courseId: "8",
                courseName: "Space and Stars",
                grade: "97%",
                color: .yellow
            ),
            .make(
                courseId: "9",
                courseName: "General Astrology",
                grade: "No Grades",
                color: .cyan
            ),
            .make(
                courseId: "10",
                courseName: "Funeral Oncology",
                grade: "-10/0",
                color: .purple
            )
        ]
        if let count, items.count > count {
            return GradeListModel(items: Array(items[0 ..< count]))
        }
        return GradeListModel(items: items)
    }
}
