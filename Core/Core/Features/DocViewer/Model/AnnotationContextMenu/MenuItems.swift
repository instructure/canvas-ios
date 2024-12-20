//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension UIAction {

    static func style(annotation: Annotation, pageView: PDFPageView) -> UIAction {
        UIAction(title: String(localized: "Style", bundle: .core)) { _ in
            pageView.presentInspector(for: [annotation])
        }
    }

    static func deleteAnnotation(document: Document, annotation: Annotation) -> UIAction {
        UIAction(title: String(localized: "Remove", bundle: .core),
                 image: .trashLine) { _ in
            document.remove(annotations: [annotation], options: nil)
        }
    }

    static func showComments(annotation: Annotation,
                             annotationMetadata: APIDocViewerAnnotationsMetadata,
                             annotationProvider: DocViewerAnnotationProvider,
                             document: Document,
                             container: UIViewController,
                             router: Router) -> UIAction {
        UIAction(title: String(localized: "Comments", bundle: .core)) { _ in
            let comments = annotationProvider.getReplies(to: annotation)
            let view = CommentListViewController.create(comments: comments,
                                                        inReplyTo: annotation,
                                                        document: document,
                                                        metadata: annotationMetadata)
            router.show(view, from: container, options: .modal(embedInNav: true))
        }
    }
}
