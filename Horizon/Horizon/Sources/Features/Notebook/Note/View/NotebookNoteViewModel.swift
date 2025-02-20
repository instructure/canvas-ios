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
import Observation

@Observable
final class NotebookNoteViewModel {

    // MARK: - Outputs
    var highlightedText: String = ""
    var isActionButtonsVisible: Bool { !isEditing && !isAdding }
    var isBackButtonHidden: Bool { isEditing }
    var isCancelVisible: Bool { isEditing && !isAdding }
    var isConfusing: Bool = false
    var isDeleteAlertPresented: Bool = false
    var isHighlightedTextVisible: Bool {
        !highlightedText.isEmpty
    }
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
    private let courseNoteInteractor: CourseNoteInteractor
    private let noteId: String?
    private let router: Router

    private var isConfusingSaved: Bool = false
    private var isImportantSaved: Bool = false
    private var noteSaved: String = ""

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var courseNote: CourseNote? {
        didSet {
            note = courseNote?.content ?? ""
            if let highlightedText = courseNote?.highlightedText, !highlightedText.isEmpty {
                self.highlightedText = "\"\(courseNote?.highlightedText ?? "")\""
            }
            noteSaved = note

            isConfusing = courseNote?.labelsList.contains { $0.toCourseNoteLabel() == .confusing } ?? false
            isConfusingSaved = isConfusing

            isImportant = courseNote?.labelsList.contains { $0.toCourseNoteLabel() == .important } ?? false
            isImportantSaved = isImportant
        }
    }

    // MARK: - Init

    init(
        courseNoteInteractor: CourseNoteInteractor,
        router: Router,
        noteId: String,
        isEditing: Bool = false
    ) {
        self.courseNoteInteractor = courseNoteInteractor
        self.router = router
        self.noteId = noteId
        self.isEditing = isEditing

        courseNoteInteractor.get(id: noteId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] courseNote in
                    self?.courseNote = courseNote
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func beginEditing() {
        if !isEditing {
            isEditing = true
        }
    }

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
        guard let noteId = noteId else { return }

        courseNoteInteractor.delete(id: noteId)
            .sink(
                receiveCompletion: { _ in
                    DispatchQueue.main.async {
                        self.router.dismiss(viewController)
                    }
                },
                receiveValue: { _ in }
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
        saveContent()
        if isAdding {
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
        noteId == nil
    }

    private func saveContent() {

        var index: NotebookHighlight?

        if let highlightKey = courseNote?.highlightKey,
           let startIndex = courseNote?.startIndex?.intValue,
           let length = courseNote?.length?.intValue,
           let highlightedText = courseNote?.highlightedText {
            index = NotebookHighlight(
                highlightKey: highlightKey,
                startIndex: startIndex,
                length: length,
                highlightedText: highlightedText
            )
        }

        if let noteId = noteId {
            let labels: [CourseNoteLabel] = [
                isConfusing ? .confusing : nil,
                isImportant ? .important : nil
            ].compactMap { $0 }

            courseNoteInteractor
                .set(
                    id: noteId,
                    content: note,
                    labels: labels,
                    index: index
                )
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &subscriptions)
        }
    }
}
