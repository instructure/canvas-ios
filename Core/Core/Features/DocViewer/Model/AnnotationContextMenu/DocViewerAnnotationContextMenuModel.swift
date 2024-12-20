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
    private let metadata: APIDocViewerMetadata?
    private let document: Document
    private let annotationProvider: DocViewerAnnotationProvider?
    private let router: Router
    private let canAnnotate: Bool

    public init(isAnnotationEnabled: Bool,
                metadata: APIDocViewerMetadata?,
                document: Document,
                annotationProvider: DocViewerAnnotationProvider?,
                router: Router) {
        self.metadata = metadata
        self.document = document
        self.annotationProvider = annotationProvider
        self.router = router
        self.canAnnotate = isAnnotationEnabled && metadata?.annotations?.enabled == true
    }

    public func menu(for annotations: [Annotation],
                     pageView: PDFPageView,
                     basedOn oldMenu: UIMenu,
                     container: UIViewController
    )
    -> UIMenu {
        // We only know what menu items to show if we receive a single tapped annotation
        guard annotations.count == 1,
              let annotation = annotations.first,
              let annotationMetadata = metadata?.annotations,
              !annotation.isFileAnnotation
        else {
            return oldMenu.replacingChildren([])
        }

        var newMenuElements: [UIMenuElement] = []

        disableRotationOnFreeTextAnnotations(annotations, pageView: pageView)

        if canAnnotate {
            let commentMenu = makeCommentMenu(for: annotation, annotationMetadata: annotationMetadata, container: container)
            newMenuElements.appendUnwrapped(commentMenu)

            switch annotation {
            case is DocViewerFreeTextAnnotation, is FreeTextAnnotation:
                newMenuElements.append(UIAction.style(annotation: annotation, pageView: pageView))
                newMenuElements.appendUnwrapped(oldMenu.firstAction(with: .PSPDFKit.editFreeText))
            case is DocViewerInkAnnotation, is DocViewerSquareAnnotation, is DocViewerPointAnnotation:
                newMenuElements.append(UIAction.style(annotation: annotation, pageView: pageView))
            default:
                break
            }

            if annotation.isDeletable {
                let action = UIAction.deleteAnnotation(document: document, annotation: annotation)
                newMenuElements.append(action)
            }
        } else if annotation.hasReplies == true {
            // Even if we can't annotate but the annotation has a comment added we should show the
            // comment menu so the user can view previous comments and add new ones to the thread
            let commentMenu = makeCommentMenu(for: annotation, annotationMetadata: annotationMetadata, container: container)
            newMenuElements.appendUnwrapped(commentMenu)
        }

        return oldMenu.replacingChildren(newMenuElements)
    }

    private func makeCommentMenu(for annotation: Annotation,
                                 annotationMetadata: APIDocViewerAnnotationsMetadata,
                                 container: UIViewController)
    -> UIMenuElement? {
        guard let annotationProvider = annotationProvider else {
            return nil
        }

        return UIAction.showComments(annotation: annotation,
                                     annotationMetadata: annotationMetadata,
                                     annotationProvider: annotationProvider,
                                     document: document,
                                     container: container,
                                     router: router)
    }

    private func disableRotationOnFreeTextAnnotations(_ annotations: [Annotation],
                                                      pageView: PDFPageView) {
        annotations.forEach {
            (pageView.annotationView(for: $0) as? FreeTextAnnotationView)?.resizableView?.allowRotating = false
        }
    }
}
