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
import WebKit

@Observable
public class NoteableTextViewModel {
    private let notebookNoteInteractor: NotebookNoteInteractor
    private var notebookCourseNotes: [NotebookCourseNote] = []
    private let router: Router?
    private var subscriptions = Set<AnyCancellable>()
    private var text: String?

    var attributedText: NSAttributedString = NSAttributedString("")

    var htmlString = "<html><head><title>Hello</title><body><p>This is a paragraph</p></body></head></html>"

    private static var viewModels = [String: NoteableTextViewModel]()

    static func build(
        text: String,
        highlightsKey: String,
        typography: HorizonUI.Typography.Name,
        notebookNoteInteractor: NotebookNoteInteractor = NotebookNoteInteractor(),
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
        notebookNoteInteractor: NotebookNoteInteractor,
        router: Router?
    ) {
        self.text = text
        self.htmlString = text
        self.notebookNoteInteractor = notebookNoteInteractor
        self.router = router

        notebookNoteInteractor.get(highlightsKey: highlightsKey).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] notebookCourseNotes in
                guard let self = self else { return }
                self.notebookCourseNotes = notebookCourseNotes
                self.attributedText = self.getAttributedText(text, typography: typography)
            }
        ).store(in: &subscriptions)
    }

    /// dynamically computes the list of menu options available when a block of text is selected
    public func getMenu(
        highlightsKey: String,
        courseId: String?,
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
                    textView: textView,
                    textRange: range,
                    courseNoteLabel: .other,
                    viewController: viewController
                )
            }
        ]

        return UIMenu(title: "", children: actions + suggestedActions)
    }

    public func getMenu(
        highlightsKey: String,
        courseId: String?,
        webView: WKWebView,
        range: NSRange,
        suggestedActions: [UIMenuElement],
        viewController: WeakViewController
    ) -> UIMenu {
//        let start = webView.
//        let end = webView.offset(from: textView.beginningOfDocument, to: range.end)
//        if firstOverlappingNotebookCourseNote(start: start, end: end) != nil {
//            return UIMenu(title: "", children: suggestedActions)
//        }
//
//        let actions: [UIMenuElement] = [
//            UIAction(title: String(localized: "Confusing", bundle: .horizon)) {_ in
//                self.onSelection(
//                    highlightsKey: highlightsKey,
//                    courseId: courseId,
//                    textView: textView,
//                    textRange: range,
//                    courseNoteLabel: .confusing,
//                    viewController: viewController
//                )
//            },
//            UIAction(title: String(localized: "Important", bundle: .horizon)) {_ in
//                self.onSelection(
//                    highlightsKey: highlightsKey,
//                    courseId: courseId,
//                    textView: textView,
//                    textRange: range,
//                    courseNoteLabel: .important,
//                    viewController: viewController
//                )
//            },
//            UIAction(title: String(localized: "Add a Note", bundle: .horizon)) {_ in
//                self.onSelection(
//                    highlightsKey: highlightsKey,
//                    courseId: courseId,
//                    textView: textView,
//                    textRange: range,
//                    courseNoteLabel: .other,
//                    viewController: viewController
//                )
//            }
//        ]

        return UIMenu(title: "", children: suggestedActions)
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
            router?.route(to: "/notebook/note/\(note.id)", from: viewController)
        }
    }

    /// Given the highlight and the type of label for a highlight, creates a new notebook note
    /// If it's chosen to add a note, then it navigates to the note page
    private func onSelection(
        highlightsKey: String,
        courseId: String?,
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
            index: NotebookNoteIndex(
                highlightKey: highlightsKey,
                startIndex: start,
                length: end - start,
                groupId: courseId
            ),
            highlightedText: highlightedText,
            labels: [courseNoteLabel]
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] courseNote in
                if courseNoteLabel == .other, let courseNote = courseNote {
                    self?.router?.route(to: "/notebook/note/\(courseNote.id)", from: viewController)
            }
        }).store(in: &subscriptions)
    }

    /// Finds the first instance of a highlight that overlaps with the start and end values passed in
    private func firstOverlappingNotebookCourseNote(start: Int, end: Int) -> NotebookCourseNote? {
        notebookCourseNotes.first { notebookCourseNote in
            let selectionStart = notebookCourseNote.highlightStart
            let selectionEnd = notebookCourseNote.highlightStart + notebookCourseNote.highlightLength
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
            let type = notebookCourseNote.types.first ?? .other
            let highlightColor = type.highlightColor.uiColor
            let range = NSRange(location: notebookCourseNote.highlightStart, length: notebookCourseNote.highlightLength)

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
