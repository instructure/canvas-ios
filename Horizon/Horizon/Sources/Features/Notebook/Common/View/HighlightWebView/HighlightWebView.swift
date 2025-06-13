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

import Combine
import Core
import HorizonUI
import SwiftUI
import WebKit

/// This override of WKWebView allows for highlighting of Web content.
final class HighlightWebView: CoreWebView {

    // MARK: - Private

    private var courseNotebookNotes: [CourseNotebookNote] = [] {
        didSet {
            Task {
                await highlightWebFeature?.apply(
                    webView: self,
                    notebookTextSelections: courseNotebookNotes.compactMap { $0.notebookTextSelection }
                )
            }
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    private var highlightWebFeature: HighlightWebFeature?
    private let actionDefinitions = [
        (label: CourseNoteLabel.confusing, title: String(localized: "Confusing", bundle: .horizon)),
        (label: CourseNoteLabel.important, title: String(localized: "Important", bundle: .horizon)),
        (label: CourseNoteLabel.other, title: String(localized: "Add a Note", bundle: .horizon))
    ]

    // MARK: - Dependencies

    private let courseID: String?
    private let courseNoteInteractor: CourseNoteInteractor
    private var currentNotebookTextSelection: NotebookTextSelection?
    private let pageURL: String?
    private let moduleType: ModuleItemType?
    private let router: Router
    private let viewController: WeakViewController?

    // MARK: - Init

    init(
        courseID: String,
        pageURL: String,
        moduleType: ModuleItemType,
        viewController: WeakViewController,
        router: Router = AppEnvironment.shared.router,
        courseNoteInteractor: CourseNoteInteractor = CourseNoteInteractorLive()
    ) {
        self.courseID = courseID
        self.pageURL = pageURL
        self.moduleType = moduleType
        self.router = router
        self.courseNoteInteractor = courseNoteInteractor
        self.viewController = viewController

        let highlightWebFeature = HighlightWebFeature()

        self.highlightWebFeature = highlightWebFeature

        super.init(features: [highlightWebFeature, .enableZoom])

        self.courseNoteInteractor.set(courseID: courseID, pageURL: pageURL)

        listenForSelectionChange()
        listenForHighlightTaps()
    }

    required init?(coder: NSCoder) {
        self.router = AppEnvironment.shared.router
        self.courseNoteInteractor = CourseNoteInteractorLive()

        self.courseID = nil
        self.pageURL = nil
        self.moduleType = nil
        self.viewController = nil
        self.highlightWebFeature = nil

        super.init(coder: coder)
    }

    // MARK: - Override Functions

    public override func buildMenu(with builder: any UIMenuBuilder) {
        // for now at least, don't allow overlapping highlights
        if isOverlapped {
            return
        }

        let actions: [UIMenuElement] = actionDefinitions.map {
            UIAction(title: $0.1, handler: onMenuAction)
        }

        let menu = UIMenu(title: "Add a Note", children: actions)
        builder.insertSibling(menu, beforeMenu: .standardEdit)
    }

    override func html(for content: String) -> String {
        // Wrap the content in a div that will be referenced by the WebHighlighting javascript
        super.html(for: "<div id=\"parent-container\"><div>\(content)</div></div>")
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        listenForHighlights()
    }

    // MARK: - Private

    private func applyHighlights(_ courseNotebookNotes: [CourseNotebookNote]) {
        self.courseNotebookNotes = courseNotebookNotes
    }

    private var isOverlapped: Bool {
        guard let currentNotebookTextSelection = currentNotebookTextSelection else {
            return false
        }
        return courseNotebookNotes.contains { courseNotebookNote in
            guard let highlightData = courseNotebookNote.highlightData else {
                return false
            }

            let startA = highlightData.textPosition.start
            let endA = highlightData.textPosition.end
            let startB = currentNotebookTextSelection.textPosition.start
            let endB = currentNotebookTextSelection.textPosition.end

            return (startA <= endB && endA >= startB) || (startA >= startB && endA <= endB)
                || (startA <= startB && endA >= endB)
        }
    }

    private func listenForHighlights() {
        guard let courseID = courseID,
            let pageURL = pageURL
        else {
            return
        }

        self.courseNoteInteractor.set(courseID: courseID, pageURL: pageURL)
        self.courseNoteInteractor.get()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] courseNotebookNotes in
                    self?.applyHighlights(courseNotebookNotes)
                }
            )
            .store(in: &subscriptions)
    }

    private func listenForHighlightTaps() {
        highlightWebFeature?.listenForHighlightTaps()
            .sink { _ in
            } receiveValue: { [weak self] notebookTextSelection in
                guard let self = self,
                    let viewController = self.viewController
                else {
                    return
                }
                if let courseNotebookNote = self.courseNotebookNotes.first(where: {
                    $0.notebookTextSelection == notebookTextSelection
                }) {
                    router.route(to: "/notebook/note", userInfo: ["note": courseNotebookNote], from: viewController)
                }
            }
            .store(in: &subscriptions)
    }

    private func listenForSelectionChange() {
        highlightWebFeature?.listenForSelectionChange()
            .sink { _ in
            } receiveValue: { [weak self] notebookTextSelection in
                self?.currentNotebookTextSelection = notebookTextSelection
            }
            .store(in: &subscriptions)
    }

    private func onMenuAction(_ action: UIAction) {
        guard let label = actionDefinitions.first(where: { action.title == $0.title })?.label,
            let courseID = courseID,
            let pageURL = pageURL,
            let viewController = self.viewController
        else {
            return
        }

        guard let notebookTextSelection = self.currentNotebookTextSelection else {
            return
        }

        let notebookHighlight = notebookTextSelection.notebookHighlight

        if label == .other,
            let urlEncodedpageURL = pageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            router.route(
                to: "/notebook/\(courseID)/add?pageURL=\(urlEncodedpageURL)", userInfo: ["notebookHighlight": notebookHighlight],
                from: viewController)
            return
        }

        courseNoteInteractor.add(
            content: "",
            labels: [label],
            notebookHighlight: notebookHighlight
        ).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] courseNote in
                guard let viewController = self?.viewController else {
                    return
                }
                if label == .other {
                    self?.router.route(to: "/notebook/note/\(courseNote.id)", from: viewController)
                }
            }
        ).store(in: &subscriptions)
    }
}

// MARK: - Extensions

extension NotebookTextSelection {
    var notebookHighlight: NotebookHighlight {
        NotebookHighlight(
            selectedText: selectedText,
            textPosition: NotebookHighlight.TextPosition(
                start: textPosition.start,
                end: textPosition.end
            ),
            range: NotebookHighlight.Range(
                startContainer: range.startContainer,
                startOffset: range.startOffset,
                endContainer: range.endContainer,
                endOffset: range.endOffset
            )
        )
    }
}

extension CourseNotebookNote {
    var notebookTextSelection: NotebookTextSelection? {
        let label = labels?.first
        guard let highlightData = highlightData else {
            return nil
        }
        return NotebookTextSelection(
            backgroundColor: label?.backgroundColorCSS ?? "\(Color.huiColors.surface.attention.hexString)33",
            borderColor: label?.borderColorCSS ?? Color.huiColors.surface.attention.hexString,
            range: .init(
                startContainer: highlightData.range.startContainer,
                endContainer: highlightData.range.endContainer,
                startOffset: highlightData.range.startOffset,
                endOffset: highlightData.range.endOffset
            ),
            selectedText: highlightData.selectedText,
            textPosition: .init(start: highlightData.textPosition.start, end: highlightData.textPosition.end)
        )
    }
}

extension CourseNoteLabel {
    var borderColorCSS: String {
        "\((color).hexString)"
    }

    var backgroundColorCSS: String {
        "\(borderColorCSS)33"  // 33 is 20% opacity
    }
}
