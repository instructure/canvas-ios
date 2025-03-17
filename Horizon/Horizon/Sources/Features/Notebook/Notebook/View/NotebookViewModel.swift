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
import Core
import Foundation

@Observable
final class NotebookViewModel {
    // MARK: - Dependencies

    private var getCourseNotesInteractor: GetCourseNotesInteractor

    // MARK: - Outputs

    var courseNoteLabels: [CourseNoteLabel] {
        CourseNoteLabel.allCases.filter { $0 != .other }
    }

    var filter: CourseNoteLabel? {
        get {
            getCourseNotesInteractor.filter
        }
        set {
            state = .loading
            getCourseNotesInteractor.filter = (self.filter == newValue ? nil : newValue)
        }
    }

    var isEmptyCardVisible: Bool { notes.isEmpty && filter == nil && state == .data && isNextDisabled && isPreviousDisabled }
    private(set) var isNextDisabled: Bool = true
    private(set) var isPreviousDisabled: Bool = true
    private(set) var notes: [NotebookNote] = []
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var title: String = ""

    // MARK: - Private variables

    private let router: Router
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Init

    init(
        getCourseNotesInteractor: GetCourseNotesInteractor = GetCourseNotesInteractorLive.shared,
        router: Router = AppEnvironment.defaultValue.router
    ) {
        self.getCourseNotesInteractor = getCourseNotesInteractor
        self.router = router

        self.title = String(localized: "Notebook", bundle: .horizon)

        loadNotes()
    }

    // MARK: - Inputs

    func onAdd(viewController: WeakViewController) {
        router.route(
            to: "/notebook/531/46036/add",
            from: viewController
        )
    }

    func onBack(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func goToModuleItem(_ note: NotebookNote, viewController: WeakViewController) {
        router.route(
            to: "/courses/\(note.courseNotebookNote.courseId)/modules/items/\(note.courseNotebookNote.objectId)",
            from: viewController
        )
    }

    func isEnabled(filter: CourseNoteLabel) -> Bool {
        self.filter == filter
    }

    func nextPage() {
        guard let cursor = notes.last?.nextCursor else { return }
        state = .loading
        getCourseNotesInteractor.cursor = Cursor(next: cursor)
    }

    func previousPage() {
        guard let cursor = notes.first?.previousCursor else { return }
        state = .loading
        getCourseNotesInteractor.cursor = Cursor(previous: cursor)
    }

    // MARK: - Private functions

    private func loadNotes() {
        weak var weakSelf = self
        getCourseNotesInteractor
            .get()
            .replaceError(with: [])
            .sink { (courseNotes: [CourseNotebookNote]) in
                guard let self = weakSelf else { return }
                self.notes = courseNotes.map { note in
                    NotebookNote(courseNotebookNote: note)
                }
                self.isNextDisabled = courseNotes.last?.nextCursor == nil
                self.isPreviousDisabled = courseNotes.first?.previousCursor == nil
                self.state = .data
            }
            .store(in: &subscriptions)
    }
}

struct NotebookNote: Identifiable {
    let courseNotebookNote: CourseNotebookNote
    var id: String { courseNotebookNote.id }
    var highlightedText: String { courseNotebookNote.highlightData?.selectedText ?? "" }
    var nextCursor: String? { courseNotebookNote.nextCursor }
    var note: String { courseNotebookNote.content ?? "" }
    var previousCursor: String? { courseNotebookNote.previousCursor }
    var title: String { formatter.string(from: courseNotebookNote.date) }
    var types: [CourseNoteLabel] { courseNotebookNote.labels ?? [] }

    private let formatter = DateFormatter()

    init(courseNotebookNote: CourseNotebookNote) {
        self.courseNotebookNote = courseNotebookNote

        formatter.dateFormat = "MMM d, yyyy"
    }
}
