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
extension API {
    struct CourseNotebookNote {
        // MARK: - Required

        var id: String
        var date: Date
        var courseId: String
        var objectId: String

        // MARK: - Optional

        var content: String?
        var highlightData: NotebookHighlight?
        var labels: [CourseNoteLabel]?
        var nextCursor: String?
        var previousCursor: String?
    }
}

extension API.CourseNotebookNote {
    init(
        from edge: RedwoodFetchNotesQueryResponse.ResponseEdge,
        pageInfo: RedwoodFetchNotesQueryResponse.PageInfo
    ) {
        let note = edge.node

        self.id = note.id ?? ""
        self.date = note.createdAt ?? Date()
        self.courseId = note.courseId
        self.objectId = note.objectId

        self.labels = note.reaction?.compactMap { .init(rawValue: $0) }

        self.content = note.userText

        self.nextCursor = pageInfo.hasNextPage ? edge.cursor : nil
        self.previousCursor = pageInfo.hasPreviousPage ? edge.cursor : nil

        self.highlightData = note.highlightData
    }

    func copy(
        date: Date? = nil,
        courseId: String? = nil,
        objectId: String? = nil,
        content: String? = nil,
        highlightData: NotebookHighlight? = nil,
        labels: [CourseNoteLabel]? = nil,
        nextCursor: String? = nil,
        previousCursor: String? = nil
    ) -> API.CourseNotebookNote {
        CourseNotebookNote(
            id: self.id,
            date: date ?? self.date,
            courseId: courseId ?? self.courseId,
            objectId: objectId ?? self.objectId,
            content: content ?? self.content,
            highlightData: highlightData ?? self.highlightData,
            labels: labels ?? self.labels,
            nextCursor: nextCursor ?? self.nextCursor,
            previousCursor: previousCursor ?? self.previousCursor
        )
    }
}

#if DEBUG
extension API.CourseNotebookNote {
    static var example: API.CourseNotebookNote {
        API.CourseNotebookNote(
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
            labels: [CourseNoteLabel.confusing]
        )
    }
}
#endif
