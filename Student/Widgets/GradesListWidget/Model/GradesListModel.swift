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

class GradesListModel: WidgetModel {
    override class var publicPreview: GradesListModel {
        Self.make()
    }

    let items: [GradesListItem?]
    let error: GradesListError?

    init(
        isLoggedIn: Bool = true,
        items: [GradesListItem?] = [],
        error: GradesListError? = nil
    ) {
        self.items = items
        self.error = error

        super.init(isLoggedIn: isLoggedIn)
    }

    func getItems(for widgetFamily: WidgetFamily) -> [GradesListItem?] {
        let maxItemCount = widgetFamily == .systemMedium ? 4 : 10
        guard items.count > maxItemCount else {
            return items
        }
        return Array(items[0 ..< maxItemCount])
    }
}

enum GradesListError: Error {
    case fetchingDataFailure
}

// MARK: - Previews

extension GradesListModel {

    static func make() -> GradesListModel {
        let items = [
            GradesListItem.make(
                courseId: "1",
                courseName: "Biology 101",
                grade: "82/100",
                color: .blue
            ),
            GradesListItem.make(
                courseId: "2",
                courseName: "Mathematics 904 2024/25",
                grade: "Good",
                color: .purple
            ),
            GradesListItem.make(
                courseId: "3",
                courseName: "English Literature 101",
                grade: "A+",
                color: .green
            ),
            GradesListItem.make(
                courseId: "4",
                courseName: "Greek Literature",
                grade: "Good",
                color: .cyan
            ),
            GradesListItem.make(
                courseId: "5",
                courseName: "Space and Stars",
                grade: "97%",
                color: .yellow
            ),
            GradesListItem.make(
                courseId: "6",
                courseName: "General Astrology",
                grade: "No Grades",
                color: .cyan
            )
        ]
        return GradesListModel(items: items)
    }

    static func makeWithOneLongCourseName() -> GradesListModel {
        let items = [
            GradesListItem.make(
                courseId: "1",
                courseName: "Biology 101",
                grade: "82/100",
                color: .blue
            ),
            GradesListItem.make(
                courseId: "2",
                courseName: "Another extremely long named course so that we can test how the view behaves when the course name is too long",
                grade: "Good",
                color: .purple
            ),
            GradesListItem.make(
                courseId: "3",
                courseName: "English Literature 101",
                grade: "A+",
                color: .green
            ),
            GradesListItem.make(
                courseId: "4",
                courseName: "Greek Literature",
                grade: "Good",
                color: .cyan
            )
        ]
        return GradesListModel(items: items)
    }

    static func makeWithLongGradeTexts() -> GradesListModel {
        let items = [
            GradesListItem.make(
                courseId: "1",
                courseName: "Biology 101",
                grade: "!!! Success !!!",
                color: .blue
            ),
            GradesListItem.make(
                courseId: "2",
                courseName: "Math 201",
                grade: "Emotional Damage Level 42",
                color: .purple
            ),
            GradesListItem.make(
                courseId: "3",
                courseName: "English Literature 101",
                grade: "You name should be failure",
                color: .green
            ),
            GradesListItem.make(
                courseId: "4",
                courseName: "Greek Literature",
                grade: "This a very unlikely long grade text",
                color: .cyan
            )
        ]
        return GradesListModel(items: items)
    }

    static func makeWithLongCourseNames() -> GradesListModel {
        let items = [
            GradesListItem.make(
                courseId: "1",
                courseName: "Long named test course so that we can test how the view behaves when the course name is too long",
                grade: "82 / 100",
                color: .blue
            ),
            GradesListItem.make(
                courseId: "2",
                courseName: "Another extremely long named course so that we can test how the view behaves when the course name is too long",
                grade: "Good",
                color: .purple
            ),
            GradesListItem.make(
                courseId: "3",
                courseName: "Yet another ridiculously long named course so that we can test how the view behaves when the course name is too long",
                grade: "Bad",
                color: .yellow
            ),
            GradesListItem.make(
                courseId: "4",
                courseName: "And yet another ridiculously long named course so that we can test how the view behaves when the course name is too long",
                grade: "20%",
                color: .green
            ),
            GradesListItem.make(
                courseId: "5",
                courseName: "Another extremely long named course so that we can test how the view behaves when the course name is too long",
                grade: "Complete",
                color: .cyan
            ),
            GradesListItem.make(
                courseId: "6",
                courseName: "Yet another ridiculously long named course so that we can test how the view behaves when the course name is too long",
                grade: "A+",
                color: .red
            ),
            GradesListItem.make(
                courseId: "7",
                courseName: "Not a long named course",
                grade: "Not Bad",
                color: .brown
            ),
            GradesListItem.make(
                courseId: "8",
                courseName: "And yet another ridiculously long named course so that we can test how the view behaves when the course name is too long",
                grade: "78%",
                color: .mint
            ),
            GradesListItem.make(
                courseId: "9",
                courseName: "Another extremely long named course so that we can test how the view behaves when the course name is too long",
                grade: "5 / 10",
                color: .teal
            ),
            GradesListItem.make(
                courseId: "10",
                courseName: "Yet another ridiculously long named course so that we can test how the view behaves when the course name is too long",
                grade: "Nice",
                color: .indigo
            )
        ]
        return GradesListModel(items: items)
    }
}
