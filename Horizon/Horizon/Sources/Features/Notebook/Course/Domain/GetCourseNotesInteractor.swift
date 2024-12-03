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
    let date: Date
    let id: String
    let note: String
    let type: NotebookNoteLabel?
}

enum NotebookNoteLabel: String, CaseIterable {
    case confusing = "Confusing"
    case important = "Important"
}

class GetCourseNotesInteractor {
    // MARK: - Dependencies

    let courseNotesRepository: CourseNotesRepository

    // MARK: - Properties

    let publisher = PassthroughSubject<[NotebookCourseNote], Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public

    func get() -> AnyPublisher<[NotebookCourseNote], Never> {
        publisher.eraseToAnyPublisher()
    }

    func search(courseId: String, text: String = "", filter: NotebookNoteLabel? = nil) {
        courseNotesRepository.get().first().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] notes in
            guard let self = self else { return }
            let courses = notes
                .sorted(by: self.sortCourseNotesByDate)
                .filter({ courseNote -> Bool in courseNote.courseId == courseId })
                .map(self.courseNoteToNotebookCourseNote)
                .filter({ notebookCourseNote -> Bool in self.filterByQueryText(text, notebookCourseNote) })
                .filter({ notebookCourseNote -> Bool in self.filterByLabel(filter, notebookCourseNote) })
            self.publisher.send(courses)
        }).store(in: &cancellables)
    }

    // MARK: - Private

    private func courseNoteToNotebookCourseNote(_ courseNote: CourseNote) -> NotebookCourseNote {
        let notebookNoteLabel = courseNote.labels.map(labelToNotebookNoteLabel).filter({$0 != nil}).map({$0!}).first
        return NotebookCourseNote(
            date: courseNote.date,
            id: courseNote.id,
            note: courseNote.content,
            type: notebookNoteLabel
        )
    }

    private func filterByQueryText(_ query: String, _ courseNote: NotebookCourseNote) -> Bool {
        query.isEmpty || courseNote.note.lowercased().contains(query.lowercased())
    }

    private func filterByLabel(_ label: NotebookNoteLabel?, _ courseNote: NotebookCourseNote) -> Bool {
        guard let label = label else { return true } // if no label is specified, all values pass
        guard let type = courseNote.type else { return false } // if no type is specified on the note but a label is specified, it does not pass
        return type.rawValue.lowercased() == label.rawValue.lowercased() // otherwise, the note passes if the type matches the label
    }

    private func labelToNotebookNoteLabel(_ label: String) -> NotebookNoteLabel? {
        NotebookNoteLabel.allCases.first { $0.rawValue.lowercased() == label.lowercased() }
    }

    private func sortCourseNotesByDate(_ a: CourseNote, _ b: CourseNote) -> Bool {
        a.date > b.date
    }
}
