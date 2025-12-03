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

#if DEBUG
final class CourseNoteInteractorPreview: CourseNoteInteractor {
    func getAllNotesWithCourses(
        pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<ListCourseNotebookNoteModel, Never> {
        Just(.init(notes: [CourseNotebookNote.example]))
            .eraseToAnyPublisher()
    }

    func add(
        courseID: String?,
        pageURL: String?,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        Just(CourseNotebookNote.example)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func delete(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getNotes(
        for pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<[CourseNotebookNote], Never> {
        Just([CourseNotebookNote.example])
            .eraseToAnyPublisher()
    }

    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, Error> {
        Just(CourseNotebookNote.example)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
