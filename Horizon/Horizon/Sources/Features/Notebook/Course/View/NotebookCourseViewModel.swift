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
import Combine

@Observable
final class NotebookCourseViewModel {
    // MARK: - Dependencies

    private let courseId: String
    private let formatter = DateFormatter()
    private let getCourseNotesInteractor: GetCourseNotesInteractor

    // MARK: - Outputs

    var filter: CourseNoteLabel? {
        get {
            getCourseNotesInteractor.filter
        }
        set {
            getCourseNotesInteractor.setFilter(self.filter == newValue ? nil : newValue)
        }
    }
    var isConfusingEnabled: Bool { filter == .confusing }
    var isImportantEnabled: Bool { filter == .important }
    var notes: [NotebookNote] = []
    var title: String = ""
    var term: String {
        get {
            getCourseNotesInteractor.term
        }
        set {
            getCourseNotesInteractor.setTerm(newValue)
        }
    }

    // MARK: - Private variables

    private let router: Router
    private var subscriptions: Set<AnyCancellable> = []

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

        weak var weakSelf = self
        getCourseNotesInteractor
            .get(courseId: courseId)
            .flatMap {
                $0.publisher
                    .map { note in
                        NotebookNote(
                            id: note.id,
                            types: note.types,
                            title: weakSelf?.formatter.string(from: note.date) ?? "",
                            note: note.note
                        )
                    }
                    .collect()
            }
            .replaceError(with: [])
            .sink { weakSelf?.notes = $0 }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func onBack(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func onNoteTapped(_ note: NotebookNote, viewController: WeakViewController) {
        router.route(to: "/notebook/note/\(note.id)", from: viewController)
    }
}

struct NotebookNote: Identifiable {
    let id: String
    let types: [CourseNoteLabel]
    let title: String
    let note: String
}