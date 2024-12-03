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

@Observable
final class NotebookCourseViewModel {
    // MARK: - Outputs

    var filter: NotebookNoteLabel? {
        getCourseNotesInteractor.filter
    }
    var isConfusingEnabled: Bool { filter == .confusing }
    var isImportantEnabled: Bool { filter == .important }
    var notes: [NotebookNote] = []
    let router: Router
    var title: String = ""

    // MARK: - Private variables

    private let courseId: String
    private let formatter = DateFormatter()
    private let getCourseNotesInteractor: GetCourseNotesInteractor
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(courseId: String,
         getCourseNotesInteractor: GetCourseNotesInteractor,
         router: Router) {
        self.courseId = courseId
        self.getCourseNotesInteractor = getCourseNotesInteractor
        self.router = router

        formatter.dateFormat = "MMM d, yyyy"

        title = String.localizedStringWithFormat(
            String(localized: "Notebook for Course %@", bundle: .horizon),
            courseId
        )

        getCourseNotesInteractor.get(courseId: courseId).sink { _ in } receiveValue: { [weak self] notes in
            let notebookNotes = notes.map { note in
                NotebookNote(
                    id: note.id,
                    type: note.type,
                    title: self?.formatter.string(from: note.date) ?? "",
                    note: note.note
                )
            }
            self?.notes = notebookNotes
        }.store(in: &cancellables)
    }

    // MARK: - Inputs

    func onFilter(_ filter: NotebookNoteLabel) {
        getCourseNotesInteractor.setFilter(self.filter == filter ? nil : filter)
    }

    func onNoteTapped(_ note: NotebookNote, viewController: WeakViewController) {
    }

    func onSearch(_ text: String) {
        getCourseNotesInteractor.setTerm(text)
    }
}

struct NotebookNote: Identifiable {
    let id: String
    let type: NotebookNoteLabel?
    let title: String
    let note: String
}
