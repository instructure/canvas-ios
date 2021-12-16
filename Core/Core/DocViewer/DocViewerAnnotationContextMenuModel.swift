//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import PSPDFKit
import PSPDFKitUI

struct DocViewerAnnotationContextMenuModel {
    public typealias CommentTapHandler = (Annotation, Document, APIDocViewerAnnotationsMetadata) -> Void
    public typealias DeleteTapHandler = (Annotation, Document) -> Void

    private let globallyDisabledMenuItems: [String] = [
        TextMenu.annotationMenuOpacity.rawValue,
        TextMenu.annotationMenuThickness.rawValue,
    ]
    private var singleAnnotationDisabledMenuItems: [String] {
        var result = globallyDisabledMenuItems
        result.append(contentsOf: [
            TextMenu.annotationMenuRemove.rawValue,
            TextMenu.annotationMenuCopy.rawValue,
            TextMenu.annotationMenuNote.rawValue,
        ])
        return result
    }
    private let commentTapHandler: CommentTapHandler
    private let deleteTapHandler: DeleteTapHandler
    private let env: AppEnvironment
    private let isAnnotationEnabled: Bool
    private let metadata: APIDocViewerMetadata?
    private let pageView: PDFPageView
    private let pdfController: PDFViewController
    private var canAnnotate: Bool { isAnnotationEnabled && metadata?.annotations?.enabled == true }

    public init(env: AppEnvironment,
                isAnnotationEnabled: Bool,
                metadata: APIDocViewerMetadata?,
                pageView: PDFPageView,
                pdfController: PDFViewController,
                commentTapHandler: @escaping CommentTapHandler,
                deleteTapHandler: @escaping DeleteTapHandler) {
        self.env = env
        self.isAnnotationEnabled = isAnnotationEnabled
        self.metadata = metadata
        self.pageView = pageView
        self.pdfController = pdfController
        self.commentTapHandler = commentTapHandler
        self.deleteTapHandler = deleteTapHandler
    }

    public func shouldShow(_ menuItems: [MenuItem], for annotations: [Annotation]) -> [MenuItem] {
        disableRotationOnFreeTextAnnotations(annotations)
        updateInspectorMenuTitle(in: menuItems)

        let isTappedOnEmptyArea = annotations.isEmpty

        if isTappedOnEmptyArea {
            // Only the teacher app should show the context menu when long tapped on an empty area
            if env.app == .teacher, canAnnotate {
                return filteredSuggestedMenuItems(menuItems)
            } else {
                return []
            }

        // Tap happened on a single annotation
        } else if annotations.count == 1, let annotation = annotations.first, let annotationMetadata = metadata?.annotations {
            if canAnnotate {
                return self.menuItems(for: annotation, suggestedMenuItems: menuItems, annotationMetadata: annotationMetadata)
            } else {
                // Even if we can't annotate but the annotation has a comment added we should show the comment menu
                // so the user can view previous comments and add new ones to the thread
                if annotation.hasReplies == true {
                    return makeCommentOnlyMenu(for: annotation, annotationMetadata: annotationMetadata)
                } else {
                    return []
                }
            }
        } else {
            if canAnnotate {
                return filteredSuggestedMenuItems(menuItems)
            } else {
                return []
            }
        }
    }

    private func menuItems(for annotation: Annotation, suggestedMenuItems: [MenuItem], annotationMetadata: APIDocViewerAnnotationsMetadata) -> [MenuItem] {
        // Annotations loaded from the pdf file shouldn't be modified
        if annotation.isFileAnnotation {
            return []
        }

        var newMenuItems: [MenuItem] = []

        addCommentMenu(to: &newMenuItems, for: annotation, annotationMetadata: annotationMetadata)
        add(suggestedMenus: suggestedMenuItems, to: &newMenuItems)
        addDeleteMenu(to: &newMenuItems, for: annotation)

        return newMenuItems
    }

    private func addCommentMenu(to menuItems: inout [MenuItem], for annotation: Annotation, annotationMetadata: APIDocViewerAnnotationsMetadata) {
        if let document = pdfController.document {
            menuItems.append(MenuItem(title: NSLocalizedString("Comments", bundle: .core, comment: "")) {
                commentTapHandler(annotation, document, annotationMetadata)
            })
        }
    }

    private func addDeleteMenu(to menuItems: inout [MenuItem], for annotation: Annotation) {
        if annotation.isDeletable, let document = pdfController.document {
            menuItems.append(MenuItem(title: NSLocalizedString("Remove", bundle: .core, comment: ""), image: .trashLine, block: {
                deleteTapHandler(annotation, document)
            }, identifier: TextMenu.annotationMenuRemove.rawValue))
        }
    }

    private func add(suggestedMenus: [MenuItem], to menuItems: inout [MenuItem]) {
        menuItems.append(contentsOf: suggestedMenus.filter {
            guard let identifier = $0.identifier else { return true }
            return !singleAnnotationDisabledMenuItems.contains(identifier)
        })
    }

    private func filteredSuggestedMenuItems(_ suggestedMenuItems: [MenuItem]) -> [MenuItem] {
        suggestedMenuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !globallyDisabledMenuItems.contains(identifier)
        }
    }

    private func makeCommentOnlyMenu(for annotation: Annotation, annotationMetadata: APIDocViewerAnnotationsMetadata) -> [MenuItem] {
        var commentOnlyMenu: [MenuItem] = []
        addCommentMenu(to: &commentOnlyMenu, for: annotation, annotationMetadata: annotationMetadata)
        return commentOnlyMenu
    }

    private func updateInspectorMenuTitle(in menuItems: [MenuItem]) {
        let inspectMenu = menuItems.first { $0.identifier == TextMenu.annotationMenuInspector.rawValue }
        inspectMenu?.title = NSLocalizedString("Style", bundle: .core, comment: "")
    }

    private func disableRotationOnFreeTextAnnotations(_ annotations: [Annotation]) {
        annotations.forEach {
            (pageView.annotationView(for: $0) as? FreeTextAnnotationView)?.resizableView?.allowRotating = false
        }
    }
}
