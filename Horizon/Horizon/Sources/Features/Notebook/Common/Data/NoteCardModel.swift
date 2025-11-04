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

struct NoteCardModel: Identifiable {
    let id: String
    let type: CourseNoteLabel
    let highlightedText: String
    let note: String?
    let date: Date
    let courseName: String?

    var dateFormatted: String {
        date.formatted(format: "MMM dd, yyyy")
    }
}

extension NoteCardModel {
    static let mockData: [NoteCardModel] = [
            NoteCardModel(
                id: UUID().uuidString,
                type: .unclear,
                highlightedText: "The definition of polymorphism needs more explanation.",
                note: "Check the lecture slides for examples.",
                date: Date().addingTimeInterval(-3600), // 1 hour ago
                courseName: "Object-Oriented Programming"
            ),
            NoteCardModel(
                id: UUID().uuidString,
                type: .important,
                highlightedText: "Encapsulation helps in reducing system complexity.",
                note: "Might come in the exam.",
                date: Date().addingTimeInterval(-86400), // 1 day ago
                courseName: "Software Engineering"
            ),
            NoteCardModel(
                id: UUID().uuidString,
                type: .unclear,
                highlightedText: "Need to clarify the difference between TCP and UDP.",
                note: nil,
                date: Date().addingTimeInterval(-172800), // 2 days ago
                courseName: "Computer Networks"
            ),
            NoteCardModel(
                id: UUID().uuidString,
                type: .important,
                highlightedText: "The formula for entropy in Information Theory.",
                note: "Memorize before the quiz.",
                date: Date().addingTimeInterval(-259200), // 3 days ago
                courseName: "Information Theory"
            ),
            NoteCardModel(
                id: UUID().uuidString,
                type: .important,
                highlightedText: "SwiftUI uses a declarative syntax for building UIs.",
                note: "Mention this in the essay question.",
                date: Date().addingTimeInterval(-604800), // 1 week ago
                courseName: "iOS Development"
            )
        ]
}
