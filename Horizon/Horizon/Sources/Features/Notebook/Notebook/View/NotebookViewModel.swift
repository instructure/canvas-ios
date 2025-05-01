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
import SwiftUI

@Observable
final class NotebookViewModel {
    // MARK: - Dependencies

    private let courseId: String?
    private var courseNoteInteractor: CourseNoteInteractor
    private let pageUrl: String?
    private let router: Router

    // MARK: - Outputs

    var courseNoteLabels: [CourseNoteLabel] {
        CourseNoteLabel.allCases.filter { $0 != .other }
    }

    var filter: CourseNoteLabel? {
        get {
            courseNoteInteractor.filter
        }
        set {
            courseNoteInteractor.set(filter: (self.filter == newValue ? nil : newValue))
        }
    }

    var isBackVisible: Bool { courseId == nil }
    var isCloseVisible: Bool { courseId != nil }
    var isEmptyCardVisible: Bool { notes.isEmpty && filter == nil && state == .data && isNextDisabled && isPreviousDisabled }
    var isFiltersVisible: Bool { courseId == nil }
    var isNavigationBarVisible: Bool { courseId == nil || pageUrl != nil }
    private(set) var isNextDisabled: Bool = true
    private(set) var isPreviousDisabled: Bool = true
    var navigationBarTopPadding: CGFloat { courseId == nil ? .zero : .huiSpaces.space24 }
    private(set) var notes: [NotebookNote] = []
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var title: String = ""

    // MARK: - Private variables

    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Init

    init(
        courseId: String? = nil,
        pageUrl: String? = nil,
        courseNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive(),
        router: Router = AppEnvironment.defaultValue.router
    ) {
        self.courseId = courseId
        self.pageUrl = pageUrl
        self.courseNoteInteractor = courseNoteInteractor
        self.router = router
        self.title = String(localized: "Notebook", bundle: .horizon)

        self.courseNoteInteractor.set(filter: nil)
        self.courseNoteInteractor.set(cursor: nil)
        self.courseNoteInteractor.set(courseID: courseId, pageURL: pageUrl)

        loadNotes()
    }

    // MARK: - Inputs

    func onBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func onClose(_ viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func goToModuleItem(_ note: NotebookNote, viewController: WeakViewController) {
        // This is just a business rule that says if the user got here from viewing a module,
        // We should not allow them to then navigate to it again.
        let isDisabled = courseId != nil && pageUrl != nil
        if isDisabled {
            return
        }
        router.route(
            to: "/courses/\(note.courseNotebookNote.courseId)/modules/items/\(note.courseNotebookNote.objectId)?asset_type=Page&notebook_disabled=true",
            from: viewController
        )
    }

    func isEnabled(filter: CourseNoteLabel) -> Bool {
        self.filter == filter
    }

    func nextPage() {
        guard let cursor = notes.last?.cursor else { return }
        state = .loading
        courseNoteInteractor.set(cursor: Cursor(next: cursor))
    }

    func previousPage() {
        guard let cursor = notes.first?.cursor else { return }
        state = .loading
        courseNoteInteractor.set(cursor: Cursor(previous: cursor))
    }

    // MARK: - Private functions

    private func loadNotes() {
        weak var weakSelf = self
        courseNoteInteractor
            .get()
            .replaceError(with: [])
            .sink { (courseNotes: [CourseNotebookNote]) in
                guard let self = weakSelf else { return }

                withAnimation {
                    self.notes = courseNotes.map { note in
                        NotebookNote(courseNotebookNote: note)
                    }
                    self.isNextDisabled = courseNotes.last?.nextCursor == nil
                    self.isPreviousDisabled = courseNotes.first?.previousCursor == nil
                    self.state = .data
                }
            }
            .store(in: &subscriptions)
    }
}

struct NotebookNote: Identifiable {
    let courseNotebookNote: CourseNotebookNote
    var id: String { courseNotebookNote.id }
    var highlightedText: String { courseNotebookNote.highlightData?.selectedText ?? "" }
    var note: String { courseNotebookNote.content ?? "" }
    var cursor: Date? { courseNotebookNote.date }
    var title: String { formatter.string(from: courseNotebookNote.date) }
    var types: [CourseNoteLabel] { courseNotebookNote.labels ?? [] }

    private let formatter = DateFormatter()

    init(courseNotebookNote: CourseNotebookNote) {
        self.courseNotebookNote = courseNotebookNote

        formatter.dateFormat = "MMM d, yyyy"
    }
}
