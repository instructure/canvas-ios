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
import Foundation

struct NotebookCourseNote {
    let id: String
    let date: Date
    let note: String
    let type: NotebookNoteLabel?
}

enum NotebookNoteLabel: String {
    case confusing = "Confusing"
    case important = "Important"
}

struct GetCourseNotesInteractor {

    let courseNotesRepository: CourseNotesRepository

    let publisher = PassthroughSubject<[NotebookCourseNote], Never>()

    var cancellables = Set<AnyCancellable>()

    func search(courseId: String, text: String = "", filter: NotebookNoteLabel? = nil) {
        courseNotesRepository.get().first().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] notes in
            let courses = notes
                .map(courseNoteTooNotebookCourseNote)
                .filter { text.isEmpty || $0.note.lowercased().contains(text.lowercased()) }
                .filter { filter == nil || $0.labels.filter { $0.lowercased() == filter.rawValue.lowercased() }.count > 0 }
                .sorted { $0.institution == $1.institution ? $0.name < $1.name : $0.institution < $1.institution }
            self?.publisher.send(courses)
        }).store(in: &cancellables)
    }
    func get() -> AnyPublisher<[NotebookCourseNote], Never> {
        publisher.eraseToAnyPublisher()
    }

    func courseNoteToNotebookCourseNote(_ courseNote: CourseNote) -> NotebookCourseNote { NotebookCourseNote(
            id: courseNote.id,
            date: courseNote.date,
            note: courseNote.note,
            type: courseNote.labels.filter { label in
                NotebookNoteLabel.allCases.map { $0.rawValue.lowercased() == label.lowercased() }.first
            }
        )
    }
}
