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

@Observable
final class NotebookNoteViewModel {

    // MARK: - Outputs
    var closeButtonOpacity: Double { isEditing && !isAdding ? 0 : 1 }
    var courseNoteLabels: [CourseNoteLabel] {
        [
            isImportant ? .important : nil,
            isConfusing ? .confusing : nil
        ].compactMap { $0 }
    }
    var highlightedText: String = ""
    var isDeleteButtonVisible: Bool { !isEditing && !isAdding }
    var isCancelVisible: Bool { isEditing && !isAdding }
    var isConfusing: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isHighlightedTextVisible: Bool {
        !highlightedText.isEmpty
    }
    var isImportant: Bool = false
    var isSaveDisabled: Bool { !isConfusing && !isImportant }
    var isSaveVisible: Bool { isEditing || isAdding }
    var isTextEditorEditable: Bool { isEditing }
    var note: String = ""
    var state: InstUI.ScreenState = .data

    // MARK: - Dependencies

    private var isEditing = false
    private let courseId: String?
    private let courseNoteInteractor: CourseNoteInteractor
    private let itemId: String?
    private let router: Router
    private let notebookHighlight: NotebookHighlight?

    private var isConfusingSaved: Bool = false
    private var isImportantSaved: Bool = false
    private var noteSaved: String = ""

    // MARK: - Private

    private var courseNote: CourseNotebookNote?
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        courseNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive.instance,
        router: Router = AppEnvironment.shared.router,
        courseNotebookNote: CourseNotebookNote,
        isEditing: Bool = false,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.courseNoteInteractor = courseNoteInteractor
        self.router = router
        self.courseNote = courseNotebookNote
        self.isEditing = isEditing
        self.scheduler = scheduler

        self.courseId = nil
        self.itemId = nil
        self.notebookHighlight = nil

        initUI()
    }

    init(
        courseNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive.instance,
        router: Router = AppEnvironment.shared.router,
        courseId: String,
        itemId: String,
        notebookHighlight: NotebookHighlight? = nil,
        isEditing: Bool = false,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.courseNoteInteractor = courseNoteInteractor
        self.router = router
        self.courseId = courseId
        self.itemId = itemId
        self.isEditing = isEditing
        self.scheduler = scheduler

        self.notebookHighlight = notebookHighlight
        self.highlightedText = notebookHighlight?.selectedText ?? ""

        self.courseNote = nil

        initUI()
    }

    // MARK: - Inputs

    func cancelEditingAndReset() {
        isEditing = false
        note = noteSaved
        isConfusing = isConfusingSaved
        isImportant = isImportantSaved
    }

    func close(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func deleteNoteAndDismiss(viewController: WeakViewController) {
        guard let noteId = courseNote?.id else { return }
        state = .loading
        courseNoteInteractor.delete(id: noteId)
            .receive(on: scheduler)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.state = .data
                    self?.router.dismiss(viewController)
                }
            )
            .store(in: &subscriptions)
    }

    func edit() {
        isEditing = true
    }

    func presentDeleteAlert() {
        isDeleteAlertPresented = true
    }

    func saveAndDismiss(viewController: WeakViewController) {
        let saveSuccess = saveContent()

        if isAdding && saveSuccess {
            router.dismiss(viewController)
        } else {
            isEditing = false
        }
    }

    func toggleConfusing() {
        isEditing = true
        isConfusing.toggle()
    }

    func toggleImportant() {
        isEditing = true
        isImportant.toggle()
    }

    // MARK: - Private

    private var isAdding: Bool {
        courseNote == nil
    }

    private func saveContent() -> Bool {
        note = note.trimmed()

        if isSaveDisabled {
            return false
        }

        let labels: [CourseNoteLabel] = [
            isConfusing ? .confusing : nil,
            isImportant ? .important : nil
        ].compactMap { $0 }

        if let noteId = courseNote?.id {
            state = .loading
            courseNoteInteractor
                .set(
                    id: noteId,
                    content: note,
                    labels: labels,
                    highlightData: courseNote?.highlightData
                )
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] _ in
                        self?.state = .data
                    }
                )
                .store(in: &subscriptions)
        }

        if let courseId = courseId, let itemId = itemId {
            state = .loading
            courseNoteInteractor
                .add(
                    courseId: courseId,
                    itemId: itemId,
                    moduleType: .subHeader,
                    content: note,
                    labels: labels,
                    notebookHighlight: notebookHighlight
                )
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] _ in
                        self?.state = .data
                    }
                )
                .store(in: &subscriptions)
        }

        return true
    }

    private func initUI() {
        note = courseNote?.content ?? ""
        if let highlightedText = courseNote?.highlightData?.selectedText, !highlightedText.isEmpty {
            self.highlightedText = "\(highlightedText)"
        }
        noteSaved = note

        isConfusing = courseNote?.labels?.contains { $0 == .confusing } ?? false
        isConfusingSaved = isConfusing

        isImportant = courseNote?.labels?.contains { $0 == .important } ?? false
        isImportantSaved = isImportant
    }
}
