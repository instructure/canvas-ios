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

    init(courseID: String,
         getCourseNotesInteractor: GetCourseNotesInteractor,
         router: Router? = nil) {
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
    }
}

struct NotebookNote: Identifiable {
    let id: String
    let type: NotebookNoteLabel?
    let title: String
    let note: String
}
