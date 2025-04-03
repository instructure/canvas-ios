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
final class NotebookNoteViewModel {
    // MARK: - Outputs

    var closeButtonDisabled: Bool { isEditing && !isAdding }
    var courseNoteLabels: [CourseNoteLabel] {
        [
            isImportant ? .important : nil,
            isConfusing ? .confusing : nil
        ].compactMap { $0 }
    }

    var highlightedText: String = ""
    var isDeleteButtonVisible: Bool { !isEditing && !isAdding }
    var isConfusing: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isHighlightedTextVisible: Bool {
        !highlightedText.isEmpty
    }

    var isImportant: Bool = false
    var isSaveDisabled: Bool { !isConfusing && !isImportant }
    var isSavedToastVisible: Bool = false
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

    func close(_ viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    @MainActor
    func deleteNoteAndDismiss(viewController: WeakViewController) {
        guard let noteId = courseNote?.id else { return }

        state = .loading

        Task {
            do {
                try await courseNoteInteractor.delete(id: noteId)
                    .receive(on: scheduler)
                    .values
                    .first { _ in true }
            } catch { }

            state = .data
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                router.dismiss(viewController)
            }
        }
    }

    func edit() {
        isEditing = true
    }

    func presentDeleteAlert() {
        isDeleteAlertPresented = true
    }

    @MainActor
    func saveAndDismiss(viewController: WeakViewController) {
        note = note.trimmed()

        if isSaveDisabled {
            return
        }

        state = .loading

        Task {

            let updated = await tryUpdate()
            if !updated {
                _ = await tryAdd()
            }

            isSavedToastVisible = true

            do {
                try await Task.sleep(nanoseconds: 2_000_000_000)
            } catch { }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.router.dismiss(viewController)
            }
        }
    }

    func toggleConfusing() {
        isEditing = true
        isImportant = false
        isConfusing = true
    }

    func toggleImportant() {
        isEditing = true
        isConfusing = false
        isImportant = true
    }

    // MARK: - Private

    private var isAdding: Bool {
        courseNote == nil
    }

    private var labels: [CourseNoteLabel] {
        [
            isConfusing ? .confusing : nil,
            isImportant ? .important : nil
        ].compactMap { $0 }
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

    private func tryAdd() async -> Bool {
        guard let courseId = courseId, let itemId = itemId else { return false }
        do {
            _ = try await courseNoteInteractor
                .add(
                    courseId: courseId,
                    itemId: itemId,
                    moduleType: .subHeader,
                    content: note,
                    labels: labels,
                    notebookHighlight: notebookHighlight
                )
                .values
                .first { _ in true }
        } catch { }

        return true
    }

    private func tryUpdate() async -> Bool {
        guard let noteId = courseNote?.id else { return false }
        do {
            _ = try await courseNoteInteractor
                .set(
                    id: noteId,
                    content: note,
                    labels: labels,
                    highlightData: courseNote?.highlightData
                )
                .values
                .first { _ in true }
        } catch { }

        return true
    }
}
