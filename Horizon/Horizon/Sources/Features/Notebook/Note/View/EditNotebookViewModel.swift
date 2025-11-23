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
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
final class EditNotebookViewModel {
    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Outputs

    private(set) var courseNote: CourseNotebookNote?
    private(set) var state: InstUI.ScreenState = .data
    private(set) var errorMessage: String = ""
    private(set) var isSaveButtonEnabled: Bool = false
    var isErrorMessagePresented = false
    let highlightedText: String
    var selectedLabel: CourseNoteLabel { didSet { validateInputs() } }
    var note: String = "" { didSet { validateInputs() } }


    // MARK: - Dependencies

    private let courseID: String?
    private let courseNoteInteractor: CourseNoteInteractor
    private let router: Router
    private let notebookHighlight: NotebookHighlight?
    private let onUpdateNote: (() -> Void)?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        courseNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive(),
        router: Router = AppEnvironment.shared.router,
        courseNotebookNote: CourseNotebookNote,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        onUpdateNote: (() -> Void)? = nil
    ) {
        self.courseNoteInteractor = courseNoteInteractor
        self.router = router
        self.courseNote = courseNotebookNote
        self.scheduler = scheduler
        self.onUpdateNote = onUpdateNote
        self.courseID = courseNotebookNote.courseId
        self.notebookHighlight = nil
        self.selectedLabel = courseNotebookNote.labels?.first ?? .important
        self.note = courseNotebookNote.content ?? ""
        self.highlightedText = courseNotebookNote.highlightData?.selectedText ?? ""
    }

    // MARK: - Input Actions

    func close(_ viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func deleteNoteAndDismiss(viewController: WeakViewController) {
        guard let noteId = courseNote?.id else { return }
        state = .loading
        courseNoteInteractor.delete(id: noteId)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.state = .data
                self?.errorMessage = error.localizedDescription
                self?.isErrorMessagePresented = true

            } receiveValue: { [weak self]  _ in
                self?.close(viewController)
            }
            .store(in: &subscriptions)
    }

    func update(viewController: WeakViewController) {
        guard let noteId = courseNote?.id else { return }
        note = note.trimmed()
        state = .loading
        courseNoteInteractor
            .set(
                id: noteId,
                content: note,
                labels: [selectedLabel],
                highlightData: courseNote?.highlightData
            )
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] error in
                self?.state = .data
                self?.errorMessage = error.localizedDescription
                self?.isErrorMessagePresented = true
            } receiveValue: { [weak self] _ in
                self?.state = .data
                self?.onUpdateNote?()
                self?.close(viewController)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Functions

    private func validateInputs() {
        let isNoteChanged = note.trimmed() != courseNote?.content?.trimmed()
        let isLabelChanged = selectedLabel != courseNote?.labels?.first
        isSaveButtonEnabled = isNoteChanged || isLabelChanged
    }
}
