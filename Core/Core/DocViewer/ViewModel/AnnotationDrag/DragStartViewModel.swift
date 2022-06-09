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

extension AnnotationDragGestureViewModel {
    struct DragStartViewModel {
        private let pdf: PDFViewController
        private let gestureRecognizer: UIGestureRecognizer
        private let pageView: PDFPageView

        public init?(pdf: PDFViewController, documentViewController: PDFDocumentViewController, gestureRecognizer: UIGestureRecognizer) {
            let tapPointInGestureView = gestureRecognizer.location(in: gestureRecognizer.view)
            guard let pageView = documentViewController.visiblePageView(at: tapPointInGestureView) else { return nil }

            self.pdf = pdf
            self.gestureRecognizer = gestureRecognizer
            self.pageView = pageView
        }

        public func startDragGesture() -> DragInfo? {
            guard
                let tappedAnnotation = tappedAnnotation(on: pageView),
                let annotationClone = createAnnotationCloneImage(tappedAnnotation, annotationFrame: annotationFrame(tappedAnnotation, on: pageView))
            else { return nil }

            removeExistingAnnotationSelections()
            let tapLocationInAnnotationClone = tapLocationInAnnotationClone(annotationClone)
            hideAnnotation(tappedAnnotation)
            return DragInfo(dragPointWithinAnnotation: tapLocationInAnnotationClone, draggedAnnotation: tappedAnnotation, annotationClone: annotationClone)
        }

        private func removeExistingAnnotationSelections() {
            pdf.selectedAnnotations = []
        }

        private func createAnnotationCloneImage(_ annotation: Annotation, annotationFrame: CGRect) -> UIImageView? {
            guard let annotationCloneImage = annotation.image(size: annotationFrame.size, options: nil) else { return nil }
            let annotationCloneImageView = UIImageView(image: annotationCloneImage)
            annotationCloneImageView.frame = annotationFrame
            pageView.addSubview(annotationCloneImageView)
            return annotationCloneImageView
        }

        private func tappedAnnotation(on pageView: PDFPageView) -> Annotation? {
            let movableAnnotations = movableAnnotations(on: pageView)
            let tapLocationInPDFCoordinates = tapLocationInPDFCoordinates
            return movableAnnotations.first { $0.hitTest(tapLocationInPDFCoordinates, minDiameter: 40) }
        }

        private var tapLocationInPDFCoordinates: CGPoint {
            let tapPointInPageView = gestureRecognizer.location(in: pageView)
            let tapPointInPdf = pageView.convert(tapPointInPageView, to: pageView.pdfCoordinateSpace)
            return tapPointInPdf
        }

        private func movableAnnotations(on pageView: PDFPageView) -> [Annotation] {
            guard let document = pdf.document else { return [] }
            let annotationsOnPage = document.annotations(at: pageView.pageIndex)
            return annotationsOnPage.filter { !$0.isReadOnly && $0.isMovable }
        }

        /** In the page view's coordinates. */
        private func annotationFrame(_ annotation: Annotation, on pageView: PDFPageView) -> CGRect {
            pageView.convert(annotation.boundingBox, from: pageView.pdfCoordinateSpace)
        }

        private func tapLocationInAnnotationClone(_ annotationClone: UIImageView) -> CGPoint {
            let tapLocationInGestureView = gestureRecognizer.location(in: gestureRecognizer.view)
            var dragPointWithinAnnotation = CGPoint.zero
            dragPointWithinAnnotation.x = tapLocationInGestureView.x - annotationClone.frame.origin.x
            dragPointWithinAnnotation.y = tapLocationInGestureView.y - annotationClone.frame.origin.y
            return dragPointWithinAnnotation
        }

        private func hideAnnotation(_ annotation: Annotation) {
            annotation.flags.update(with: .hidden)

            // These two lines will update the screen way faster than sending out the changed notification and also don't trigger an API upload
            PSPDFKit.SDK.shared.cache.remove(for: pdf.document)
            pdf.visiblePageViews.forEach { $0.update() }
        }
    }
}
