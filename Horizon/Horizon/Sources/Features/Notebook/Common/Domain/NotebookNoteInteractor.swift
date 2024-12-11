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

final class NotebookNoteInteractor {
    // MARK: - Dependencies

    private let courseNotesRepository: CourseNotesRepository

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public

    func delete(noteId: String) -> Future<Void, Error> {
        courseNotesRepository.delete(id: noteId)
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
