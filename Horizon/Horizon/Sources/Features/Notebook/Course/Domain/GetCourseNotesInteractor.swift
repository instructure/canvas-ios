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
    let types: [CourseNoteLabel]

    init(from courseNote: CourseNote) {
        date = courseNote.date
        id = courseNote.id
        note = courseNote.content
        types = courseNote.labels
    }
}

final class GetCourseNotesInteractor {
    // MARK: - Dependencies

    let courseNotesRepository: CourseNotesRepository

    // MARK: - Public

    var filter: CourseNoteLabel? {
        filterPublisher.value
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var termPublisher: CurrentValueSubject<String, Error> = CurrentValueSubject("")
    var term: String {
        termPublisher.value
    }
    private var filterPublisher: CurrentValueSubject<CourseNoteLabel?, Error> = CurrentValueSubject(nil)

    // MARK: - Init

    init(courseNotesRepository: CourseNotesRepository) {
        self.courseNotesRepository = courseNotesRepository
    }

    // MARK: - Public Methods

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

    func setFilter(_ filter: CourseNoteLabel?) {
        filterPublisher.send(filter)
    }

    // MARK: - Private Methods

    private func filterByLabel(notes: [NotebookCourseNote], filter: CourseNoteLabel?) -> [NotebookCourseNote] {
        notes.filter { note in
            guard let filter = filter else { return true } // if no label is specified, all values pass
            return note.types.contains(filter) // otherwise, the note passes if the type matches the label
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
