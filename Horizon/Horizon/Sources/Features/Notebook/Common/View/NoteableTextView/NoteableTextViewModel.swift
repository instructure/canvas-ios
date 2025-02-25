//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import SwiftUI
import HorizonUI
import Combine
import Core

@Observable
public class NoteableTextViewModel {
    private let notebookNoteInteractor: CourseNoteInteractor
    private var notebookCourseNotes: [CourseNotebookNote] = []
    private let router: Router?
    private var subscriptions = Set<AnyCancellable>()
    private var text: String?

    var attributedText: NSAttributedString = NSAttributedString("")

    private static var viewModels = [String: NoteableTextViewModel]()

    static func build(
        text: String,
        highlightsKey: String,
        typography: HorizonUI.Typography.Name,
        notebookNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive(),
        router: Router = AppEnvironment.shared.router
    ) -> NoteableTextViewModel {
        let viewModel = viewModels[highlightsKey] ?? NoteableTextViewModel(
            text: text,
            highlightsKey: highlightsKey,
            typography: typography,
            notebookNoteInteractor: notebookNoteInteractor,
            router: router
        )
        viewModels[highlightsKey] = viewModel
        return viewModel
    }

    private init(
        text: String,
        highlightsKey: String,
        typography: HorizonUI.Typography.Name,
        notebookNoteInteractor: CourseNoteInteractor,
        router: Router?
    ) {
        self.text = text
        self.notebookNoteInteractor = notebookNoteInteractor
        self.router = router
    }

    /// dynamically computes the list of menu options available when a block of text is selected
    public func getMenu(
        highlightsKey: String,
        courseId: String,
        itemId: String,
        moduleType: ModuleItemType,
        textView: UITextView,
        range: UITextRange,
        suggestedActions: [UIMenuElement],
        viewController: WeakViewController
    ) -> UIMenu {
        let start = textView.offset(from: textView.beginningOfDocument, to: range.start)
        let end = textView.offset(from: textView.beginningOfDocument, to: range.end)
        if firstOverlappingNotebookCourseNote(start: start, end: end) != nil {
            return UIMenu(title: "", children: suggestedActions)
        }

        let actions: [UIMenuElement] = [
            UIAction(title: String(localized: "Confusing", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: courseId,
                    itemId: itemId,
                    moduleType: moduleType,
                    textView: textView,
                    textRange: range,
                    courseNoteLabel: .confusing,
                    viewController: viewController
                )
            },
            UIAction(title: String(localized: "Important", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: courseId,
                    itemId: itemId,
                    moduleType: moduleType,
                    textView: textView,
                    textRange: range,
                    courseNoteLabel: .important,
                    viewController: viewController
                )
            },
            UIAction(title: String(localized: "Add a Note", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: courseId,
                    itemId: itemId,
                    moduleType: moduleType,
                    textView: textView,
                    textRange: range,
                    courseNoteLabel: .other,
                    viewController: viewController
                )
            }
        ]

        return UIMenu(title: "", children: actions + suggestedActions)
    }

    /// finds the block of text highlighted within a text view (if any) and navigates to the note page if found
    public func onTap(viewController: WeakViewController, gesture: UITapGestureRecognizer) {
        guard let textView = gesture.view as? UITextView else {
            return
        }
        let location = gesture.location(in: textView)
        guard let textPosition = textView.closestPosition(to: location) else {
            return
        }

        let start = textView.offset(from: textView.beginningOfDocument, to: textPosition)
        let end = start + 1

        if let note = firstOverlappingNotebookCourseNote(start: start, end: end) {
            router?.route(to: "/notebook/note", userInfo: ["note": note], from: viewController)
        }
    }

    /// Given the highlight and the type of label for a highlight, creates a new notebook note
    /// If it's chosen to add a note, then it navigates to the note page
    private func onSelection(
        highlightsKey: String,
        courseId: String,
        itemId: String,
        moduleType: ModuleItemType,
        textView: UITextView,
        textRange: UITextRange,
        courseNoteLabel: CourseNoteLabel,
        viewController: WeakViewController
    ) {
        let start = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let end = textView.offset(from: textView.beginningOfDocument, to: textRange.end)

        // don't allow overlap
        if end <= start || firstOverlappingNotebookCourseNote(start: start, end: end) != nil {
            return
        }

        let highlightedText = textView.text(in: textRange) ?? ""

        notebookNoteInteractor.add(
            courseId: courseId,
            itemId: itemId,
            moduleType: moduleType,
            content: "",
            labels: [courseNoteLabel],
            index: NotebookHighlight(
                highlightKey: highlightsKey,
                startIndex: start,
                length: end - start,
                highlightedText: highlightedText
            )
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] courseNote in
                if courseNoteLabel == .other {
                    self?.router?.route(
                        to: "/notebook/note",
                        userInfo: ["note": courseNote],
                        from: viewController
                    )
                }
            }
        ).store(in: &subscriptions)
    }

    /// Finds the first instance of a highlight that overlaps with the start and end values passed in
    private func firstOverlappingNotebookCourseNote(start: Int, end: Int) -> CourseNotebookNote? {
        notebookCourseNotes.first { notebookCourseNote in
            guard let selectionStart = notebookCourseNote.startIndex,
                  let length = notebookCourseNote.length else {
                return false
            }
            let selectionEnd = selectionStart + length
            return (start < selectionStart && end > selectionStart) || (start < selectionEnd && end > selectionEnd)
                || (start >= selectionStart && end <= selectionEnd)
        }
    }

    /// Creates the attributed string given the text and typography, with the highlights applied
    private func getAttributedText(_ text: String, typography: HorizonUI.Typography.Name) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = typography.lineHeightMultiple

        attributedText.addAttributes(
            [
                .font: HorizonUI.fonts.uiFont(font: typography.font),
                .kern: typography.letterSpacing,
                .paragraphStyle: paragraphStyle
            ],
            range: NSRange(location: 0, length: text.count)
        )

        notebookCourseNotes.forEach { notebookCourseNote in
            guard let startIndex = notebookCourseNote.startIndex,
                    let length = notebookCourseNote.length else {
                return
            }

            let type = notebookCourseNote.labels?.first ?? .other
            let highlightColor = type.highlightColor.uiColor
            let range = NSRange(location: startIndex, length: length)

            attributedText.addAttribute(
                .backgroundColor,
                value: highlightColor,
                range: range
            )
        }

        return attributedText
    }
}

extension CourseNoteLabel {
    var highlightColor: Color {
        color?.opacity(0.10) ?? Color(red: 96.1/100, green: 91.4/100, blue: 79.2/100)
    }
}
