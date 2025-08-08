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
struct CourseNotebookNote {
    // MARK: - Required

    var id: String
    var date: Date
    var courseId: String
    var hasNext: Bool
    var hasPrevious: Bool
    var objectId: String

    // MARK: - Optional

    var content: String?
    var highlightData: NotebookHighlight?
    var labels: [CourseNoteLabel]?
}

extension CourseNotebookNote {
    init(
        from edge: RedwoodFetchNotesQueryResponse.ResponseEdge,
        pageInfo: RedwoodFetchNotesQueryResponse.PageInfo
    ) {
        let note = edge.node

        self.id = note.id
        self.date = note.createdAt
        self.courseId = note.courseId
        self.objectId = note.objectId
        self.hasNext = false
        self.hasPrevious = false

        self.labels = note.reaction?.compactMap { .init(rawValue: $0) }

        self.content = note.userText

        self.highlightData = note.highlightData

    }

    func copy(
        date: Date? = nil,
        courseId: String? = nil,
        objectId: String? = nil,
        content: String? = nil,
        highlightData: NotebookHighlight? = nil,
        labels: [CourseNoteLabel]? = nil,
        hasPrevious: Bool = false,
        hasNext: Bool = false
    ) -> CourseNotebookNote {
        CourseNotebookNote(
            id: self.id,
            date: date ?? self.date,
            courseId: courseId ?? self.courseId,
            hasNext: hasNext,
            hasPrevious: hasPrevious,
            objectId: objectId ?? self.objectId,
            content: content ?? self.content,
            highlightData: highlightData ?? self.highlightData,
            labels: labels ?? self.labels
        )
    }
}

extension CourseNotebookNote {
    init(from note: RedwoodNote) {
        self.id = note.id
        self.date = note.createdAt
        self.courseId = note.courseId
        self.objectId = note.objectId

        self.content = note.userText
        self.labels = note.reaction?.compactMap { CourseNoteLabel(rawValue: $0) } ?? []

        self.highlightData = note.highlightData
        self.hasNext = false
        self.hasPrevious = false
    }
}

#if DEBUG
extension CourseNotebookNote {
    static var example: CourseNotebookNote {
        CourseNotebookNote(
            id: "1",
            date: Date(),
            courseId: "courseID",
            hasNext: false,
            hasPrevious: false,
            objectId: "objectID",
            content: "Good morning",
            highlightData: NotebookHighlight(
                selectedText: "Selected Text",
                textPosition: NotebookHighlight.TextPosition(start: 0, end: 0),
                range: NotebookHighlight.Range(startContainer: "", startOffset: 0, endContainer: "", endOffset: 0)
            ),
            labels: [CourseNoteLabel.confusing]
        )
    }
}
#endif
