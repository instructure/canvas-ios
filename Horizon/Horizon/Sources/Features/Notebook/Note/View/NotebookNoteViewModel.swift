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
import Observation
import Core

@Observable
final class NotebookNoteViewModel {

    // MARK: - Outputs

    var isActionButtonsVisible: Bool { !isEditing }
    var isConfusing: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isImportant: Bool = false
    var isSaveVisible: Bool { isEditing }
    var isTextEditorDisabled: Bool { !isEditing }
    var note: String = ""
    var title: String {
        isEditing ?
            String(localized: "Edit", bundle: .horizon) :
            String(localized: "Note", bundle: .horizon)
    }

    // MARK: - Dependencies

    private var isEditing = false
    private let notebookNoteInteractor: NotebookNoteInteractor
    private let noteId: String
    private let router: Router

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(notebookNoteInteractor: NotebookNoteInteractor,
         noteId: String,
         router: Router,
         isEditing: Bool = false
    ) {
        self.notebookNoteInteractor = notebookNoteInteractor
        self.noteId = noteId
        self.router = router
        self.isEditing = isEditing

        notebookNoteInteractor.get(noteId: noteId)
            .sink { _ in }
            receiveValue: { [weak self] note in
                self?.note = note?.note ?? ""
                self?.isConfusing = note?.types.contains(.confusing) ?? false
                self?.isImportant = note?.types.contains(.important) ?? false
            }.store(in: &subscriptions)
    }

    // MARK: - Inputs

    func onClose(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func onDelete() {
        isDeleteAlertPresented = true
    }

    func onDeleteConfirmed(viewController: WeakViewController) {
        notebookNoteInteractor.delete(noteId: noteId)
            .sink { _ in
                self.router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    func onEdit() {
        isEditing = true
    }

    func onSave() {
        isEditing = false
        onTextChange()
    }

    func onTapTextEditor() {
        if !isEditing {
            isEditing = true
        }
    }

    func onToggleConfusing() {
        var labels: [CourseNoteLabel] = []
        if !isConfusing {
            labels.append(.confusing)
        }
        if isImportant {
            labels.append(.important)
        }
        notebookNoteInteractor
            .update(noteId: noteId, labels: labels)
            .sink { _ in }
            .store(in: &subscriptions)
    }

    func onToggleImportant() {
        var labels: [CourseNoteLabel] = []
        if isConfusing {
            labels.append(.confusing)
        }
        if !isImportant {
            labels.append(.important)
        }
        notebookNoteInteractor
            .update(noteId: noteId, labels: labels)
            .sink { _ in }
            .store(in: &subscriptions)
    }

    // MARK: - Private

    private func onTextChange() {
        notebookNoteInteractor
            .update(noteId: noteId, content: note)
            .sink { _ in }
            .store(in: &subscriptions)
    }
}
