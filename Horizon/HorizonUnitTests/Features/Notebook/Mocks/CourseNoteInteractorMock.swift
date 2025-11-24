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

import Combine
@testable import Horizon
import Foundation

final class CourseNoteInteractorMock: CourseNoteInteractor {
    var setCallCount = 0
    var deleteCallCount = 0
    var lastSetParams: (id: String, content: String?, labels: [CourseNoteLabel]?, highlightData: NotebookHighlight?)?
    var lastDeletedId: String?
    var shouldFailSet = false
    var shouldFailDelete = false
    var noteToReturn = CourseNotebookNote.example

    func getAllNotesWithCourses(
        pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<ListCourseNotebookNoteModel, Never> {
        Just(ListCourseNotebookNoteModel()).eraseToAnyPublisher()
    }

    func add(
        courseID: String?,
        pageURL: String?,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        let note = CourseNotebookNote(
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

        return Just(note)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<Void, Error> {
        deleteCallCount += 1
        lastDeletedId = id
        if shouldFailDelete {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }

    func getNotes(
        for pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<[CourseNotebookNote], Never> {
        Just([noteToReturn]).eraseToAnyPublisher()
    }

    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        setCallCount += 1
        lastSetParams = (id, content, labels, highlightData)
        if shouldFailSet {
            return Fail(error: .unableToCreateNote).eraseToAnyPublisher()
        } else {
            var updatedNote = noteToReturn
            updatedNote.content = content
            updatedNote.labels = labels
            return Just(updatedNote).setFailureType(to: NotebookError.self).eraseToAnyPublisher()
        }
    }
}
