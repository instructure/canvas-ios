//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct NotebookNoteIndex {
    /// The NotebookNoteIndex is used to index where an annotation belongs
    /// The highlightKey is globally unique to the block of text that's being highlighted. This for example might be a single paragraph. It may have multiple highlights.
    /// The startIndex is the index of the first character in the highlight
    /// The length is the number of characters in the highlight
    /// The groupId indicates that this highlight is part of a larger group of highlights (e.g., a course)
    let highlightKey: String
    let startIndex: Int
    let length: Int
    let groupId: String?
}

final class NotebookNoteInteractor {
    // MARK: - Dependencies

    private let courseNotesRepository: CourseNotesRepository

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository = CourseNotesRepositoryPreview.instance) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public

    func add(index: NotebookNoteIndex,
             content: String? = nil,
             highlightedText: String,
             labels: [CourseNoteLabel]? = nil) -> Future<CourseNote?, Error> {
        courseNotesRepository.add(
            index: index,
            highlightedText: highlightedText,
            content: content,
            labels: labels
        )
    }

    func delete(noteId: String) -> Future<Void, Error> {
        courseNotesRepository.delete(id: noteId)
    }

    func get(highlightsKey: String) -> AnyPublisher<[NotebookCourseNote], Error> {
        courseNotesRepository.get()
            .map { notes in notes.filter { $0.highlightKey == highlightsKey }}
            .map { notes in notes.map { NotebookCourseNote(from: $0) }}
            .eraseToAnyPublisher()
    }

    func get(noteId: String) -> AnyPublisher<NotebookCourseNote?, Error> {
        courseNotesRepository.get()
            .map { notes in notes.first { $0.id == noteId }}
            .map { note in
                guard let note = note else { return nil }
                return NotebookCourseNote(from: note)
            }
            .eraseToAnyPublisher()
    }

    func update(
        noteId: String,
        content: String? = nil,
        labels: [CourseNoteLabel]? = nil
    ) -> Future<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.courseNotesRepository.set(
                id: noteId,
                content: content,
                labels: labels
            ).sink { _ in
                promise(.success(()))
            }.store(in: &self.subscriptions)
        }
    }
}
