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

import Core
import SwiftUI
import Combine

@Observable final class NotebookCourseViewModel {
    var title: String = ""

    var notes: [NotebookNote] = []

    let router: Router?

    private var getCoursesNotesCancellable: AnyCancellable?

    private let formatter = DateFormatter()

    private let courseID: String

    private let getCourseNotesInteractor: GetCourseNotesInteractor

    var filter: NotebookNoteLabel? {
        didSet {
            executeSearch()
        }
    }

    private var search: String = "" {
        didSet {
            executeSearch()
        }
    }

    var isConfusingEnabled: Bool { filter == .confusing }

    var isImportantEnabled: Bool { filter == .important }

    init(courseID: String,
         getCourseNotesInteractor: GetCourseNotesInteractor,
         router: Router? = nil) {
        self.courseID = courseID
        self.getCourseNotesInteractor = getCourseNotesInteractor
        self.router = router

        formatter.dateFormat = "MMM d, yyyy"

        title = "Notebook for Course \(courseID)"

        getCoursesNotesCancellable = getCourseNotesInteractor.get().sink { _ in } receiveValue: { [weak self] notes in
            let notebookNotes = notes.map { note in
                NotebookNote(
                    id: note.id,
                    type: note.type,
                    title: self?.formatter.string(from: note.date) ?? "",
                    note: note.note
                )
            }
            self?.notes = notebookNotes
        }

        getCourseNotesInteractor.search(courseId: courseID)
    }

    func onFilter(_ filter: NotebookNoteLabel) {
        self.filter = self.filter == filter ? nil : filter
    }

    func onNoteTapped(_ note: NotebookNote, viewController: WeakViewController) {
    }

    func onSearch(_ text: String) {
        self.search = text
    }

    private func executeSearch() {
        getCourseNotesInteractor.search(courseId: courseID, text: search, filter: filter)
    }
}

struct NotebookNote: Identifiable {
    let id: String
    let type: NotebookNoteLabel?
    let title: String
    let note: String
}
