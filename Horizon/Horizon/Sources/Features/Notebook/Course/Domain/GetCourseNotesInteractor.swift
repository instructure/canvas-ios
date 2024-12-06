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

    init(from courseNote: CourseNote) {
        let notebookNoteLabel = courseNote.labels
          .map { label in
              NotebookNoteLabel.allCases.first {
                  $0.rawValue.lowercased() == label.lowercased()
              }
          }
          .filter {$0 != nil}
          .map {$0!}
          .first

        date = courseNote.date
        id = courseNote.id
        note = courseNote.content
        type = notebookNoteLabel
    }
}

enum NotebookNoteLabel: String, CaseIterable {
    case confusing = "Confusing"
    case important = "Important"
}

final class GetCourseNotesInteractor {
    // MARK: - Dependencies

    let courseNotesRepository: CourseNotesRepository

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()
    private var termPublisher: CurrentValueSubject<String, Error> = CurrentValueSubject("")
    var term: String {
        termPublisher.value
    }
    private var filterPublisher: CurrentValueSubject<NotebookNoteLabel?, Error> = CurrentValueSubject(nil)
    var filter: NotebookNoteLabel? {
        filterPublisher.value
    }

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public

    func get(courseId: String) -> AnyPublisher<[NotebookCourseNote], Error> {
        courseNotesRepository.get()
            .map(sortByDate)
            .map {notes in notes.filter { note in note.courseId == courseId } }
            .map(toNotebookCourseNotes)
            .combineLatest(termPublisher.map({$0.lowercased()}))
            .map(filterByTerm)
            .combineLatest(filterPublisher)
            .map(filterByLabel)
            .eraseToAnyPublisher()
    }

    func setTerm(_ term: String) {
        termPublisher.send(term)
    }

    func setFilter(_ filter: NotebookNoteLabel?) {
        filterPublisher.send(filter)
    }

    // MARK: - Private

    private func filterByLabel(notes: [NotebookCourseNote], filter: NotebookNoteLabel?) -> [NotebookCourseNote] {
        notes.filter { note in
            guard let filter = filter else { return true } // if no label is specified, all values pass
            guard let type = note.type else { return false } // if no type is specified on the note but a label is specified, it does not pass
            return type.rawValue.lowercased() == filter.rawValue.lowercased() // otherwise, the note passes if the type matches the label
        }
    }

    private func filterByTerm(notes: [NotebookCourseNote], term: String) -> [NotebookCourseNote] {
        notes.filter { term.isEmpty || $0.note.lowercased().contains(term.lowercased()) }
    }

    private func sortByDate(_ notes: [CourseNote]) -> [CourseNote] {
        notes.sorted(by: { $0.date > $1.date })
    }

    private func toNotebookCourseNotes(_ notes: [CourseNote]) -> [NotebookCourseNote] {
        notes.map { courseNote in NotebookCourseNote(from: courseNote) }
    }
}
