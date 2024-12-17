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

    var isActionButtonsVisible: Bool { !isEditing && !isAdding }
    var isBackButtonHidden: Bool { isEditing }
    var isCancelVisible: Bool { isEditing && !isAdding }
    var isConfusing: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isImportant: Bool = false
    var isSaveDisabled: Bool { !isConfusing && !isImportant && note.isEmpty }
    var isSaveVisible: Bool { isEditing || isAdding }
    var isTextEditorDisabled: Bool { !isEditing }
    var note: String = ""
    var title: String {
        String(localized: isEditing && !isAdding ? "Edit" : "Note", bundle: .horizon)
    }

    // MARK: - Dependencies

    private var isEditing = false
    private let notebookNoteInteractor: NotebookNoteInteractor
    private let noteId: String?
    private let courseId: String?
    private let highlightedText: String?
    private let router: Router

    private var isConfusingSaved: Bool = false
    private var isImportantSaved: Bool = false
    private var noteSaved: String = ""

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(notebookNoteInteractor: NotebookNoteInteractor,
         router: Router,
         noteId: String,
         isEditing: Bool = false) {
        self.notebookNoteInteractor = notebookNoteInteractor
        self.router = router
        self.noteId = noteId
        self.isEditing = isEditing
        self.courseId = nil
        self.highlightedText = nil

        notebookNoteInteractor.get(noteId: noteId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: whenNotebookCourseNoteUpdated)
            .store(in: &subscriptions)
    }

    init(notebookNoteInteractor: NotebookNoteInteractor,
         router: Router,
         courseId: String,
         highlightedText: String) {
        self.notebookNoteInteractor = notebookNoteInteractor
        self.router = router
        self.courseId = courseId
        self.noteId = nil
        self.isEditing = true
        self.highlightedText = highlightedText
    }

    // MARK: - Inputs

    func onCancel() {
        isEditing = false
        note = noteSaved
        isConfusing = isConfusingSaved
        isImportant = isImportantSaved
    }

    func onClose(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func onDelete() {
        isDeleteAlertPresented = true
    }

    func onDeleteConfirmed(viewController: WeakViewController) {
        guard let noteId = noteId else { return }

        notebookNoteInteractor.delete(noteId: noteId)
            .sink { _ in
                self.router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    func onEdit() {
        isEditing = true
    }

    func onSave(viewController: WeakViewController) {
        saveContent()
        if isAdding {
            router.dismiss(viewController)
        } else {
            isEditing = false
        }
    }

    func onTapTextEditor() {
        if !isEditing {
            isEditing = true
        }
    }

    func onToggleConfusing() {
        isEditing = true
        isConfusing.toggle()
    }

    func onToggleImportant() {
        isEditing = true
        isImportant.toggle()
    }

    // MARK: - Private

    private func whenNotebookCourseNoteUpdated(notebookCourseNote: NotebookCourseNote?) {
        note = notebookCourseNote?.note ?? ""
        noteSaved = note

        isConfusing = notebookCourseNote?.types.contains(.confusing) ?? false
        isConfusingSaved = isConfusing

        isImportant = notebookCourseNote?.types.contains(.important) ?? false
        isImportantSaved = isImportant
    }

    private var isAdding: Bool {
        noteId == nil
    }

    private func saveContent() {
        saveLabels()
        if let noteId = noteId {
            notebookNoteInteractor
                .update(noteId: noteId, content: note)
                .sink { _ in }
                .store(in: &subscriptions)
        } else if let courseId = courseId,
                  let highlightedText = highlightedText {
            notebookNoteInteractor
                .add(courseId: courseId,
                     highlightedText: highlightedText,
                     content: note,
                     labels: getCourseNoteLabels)
                .sink { _ in }
                .store(in: &subscriptions)
        }
    }

    private func saveLabels() {
        guard let noteId = noteId else { return }

        var labels: [CourseNoteLabel] = []
        if isConfusing {
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

    private var getCourseNoteLabels: [CourseNoteLabel] {
        var labels: [CourseNoteLabel] = []
        if isConfusing {
            labels.append(.confusing)
        }
        if isImportant {
            labels.append(.important)
        }
        return labels
    }
}
