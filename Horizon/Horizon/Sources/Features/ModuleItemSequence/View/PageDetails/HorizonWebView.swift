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

import Core
import Combine

final class HorizonWebView: CoreWebView {
    private let notebookNoteInteractor: NotebookNoteInteractor
    private var notebookCourseNotes: [NotebookCourseNote] = []
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private let highlightsKey: String?
    private let courseId: String?

    init(
        highlightsKey: String,
        courseId: String? = nil,
        router: Router = AppEnvironment.shared.router,
        notebookNoteInteractor: NotebookNoteInteractor = NotebookNoteInteractor()
    ) {
        self.router = router
        self.notebookNoteInteractor = notebookNoteInteractor
        self.highlightsKey = highlightsKey
        self.courseId = courseId

        super.init(features: [
            HighlightWebFeature()
        ])
    }

    required init?(coder: NSCoder) {
        self.router = AppEnvironment.shared.router
        self.notebookNoteInteractor = NotebookNoteInteractor()
        self.highlightsKey = nil
        self.courseId = nil

        super.init(coder: coder)
    }

    // TODO: The menu appears as a sub-menu. Is there a way to change this?
    public override func buildMenu(with builder: any UIMenuBuilder) {
        guard let highlightsKey = highlightsKey else {
            return
        }

        let actions: [UIMenuElement] = [
            UIAction(title: String(localized: "Confusing", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: self.courseId,
                    highlightedText: "",
                    courseNoteLabel: .confusing
                )
            },
            UIAction(title: String(localized: "Important", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: self.courseId,
                    highlightedText: "",
                    courseNoteLabel: .important
                )
            },
            UIAction(title: String(localized: "Add a Note", bundle: .horizon)) {_ in
                self.onSelection(
                    highlightsKey: highlightsKey,
                    courseId: self.courseId,
                    highlightedText: "",
                    courseNoteLabel: .other
                )
            }
        ]

        let menu = UIMenu(title: "Notebook", children: actions)
        builder.insertSibling(menu, beforeMenu: .standardEdit)
    }

    /// Given the highlight and the type of label for a highlight, creates a new notebook note
    /// If it's chosen to add a note, then it navigates to the note page
    private func onSelection(
        highlightsKey: String,
        courseId: String?,
        highlightedText: String,
        courseNoteLabel: CourseNoteLabel,
        viewController: WeakViewController? = nil // TODO: Pass in a view controller
    ) {
        notebookNoteInteractor.add(
            index: NotebookNoteIndex(
                highlightKey: highlightsKey,
                startIndex: 0, // TODO: Put real values here
                length: 0,
                groupId: courseId
            ),
            highlightedText: highlightedText,
            labels: [courseNoteLabel]
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] courseNote in
                guard let viewController = viewController else {
                    return
                }
                if courseNoteLabel == .other, let courseNote = courseNote {
                    self?.router.route(to: "/notebook/note/\(courseNote.id)", from: viewController)
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
}
