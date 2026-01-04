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
import Foundation

/// This is an API agnostic entity model.
/// It's used in the interactors and can be used in the views, but will normally be translated to a view model before being used in the views.
struct CourseNotebookNote: Equatable, Identifiable {
    // MARK: - Required

    var id: String
    var date: Date
    var courseId: String
    var courseName: String?
    var objectId: String

    // MARK: - Optional

    var content: String?
    var highlightData: NotebookHighlight?
    var labels: [CourseNoteLabel]?

    var type: CourseNoteLabel {
        labels?.first ?? .important
    }

    var highlightedText: String {
        highlightData?.selectedText ?? ""
    }

    var dateFormatted: String {
        date.formatted(format: "MMM dd, yyyy")
    }

    func getAccessliblityLabel(isCourseNameVisible: Bool = true) -> String {
        var description = String(format: String(localized: "Note label is %@. "), type.label)
        description += String(format: String(localized: "Highlighted text is %@. "), highlightedText)
        description += String(format: String(localized: "Added at %@. "), dateFormatted)

        if isCourseNameVisible {
            description += String(format: String(localized: "Course name is %@. "), courseName ?? "")
        }
        description += String(localized: "Delete note is available. ")
        return description
    }
}

struct ListCourseNotebookNoteModel: Equatable {
    let notes: [CourseNotebookNote]
    let courses: [DropdownMenuItem]

    init(
        notes: [CourseNotebookNote] = [],
        courses: [DropdownMenuItem] = []
    ) {
        self.notes = notes
        self.courses = courses
    }
}

#if DEBUG
extension CourseNotebookNote {
    static var example: CourseNotebookNote {
        CourseNotebookNote(
            id: "1",
            date: Date(),
            courseId: "courseID",
            objectId: "objectID",
            content: "Good morning",
            highlightData: NotebookHighlight(
                selectedText: "Selected Text",
                textPosition: NotebookHighlight.TextPosition(start: 0, end: 0),
                range: NotebookHighlight.Range(startContainer: "", startOffset: 0, endContainer: "", endOffset: 0)
            ),
            labels: [CourseNoteLabel.unclear]
        )
    }
}
#endif
