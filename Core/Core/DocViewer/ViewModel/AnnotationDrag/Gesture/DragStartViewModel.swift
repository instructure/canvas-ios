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
            guard let pageView = documentViewController.visiblePageView(at: tapPointInGestureView) else {
                gestureRecognizer.cancel()
                return nil
            }

            self.pdf = pdf
            self.gestureRecognizer = gestureRecognizer
            self.pageView = pageView
        }

        public func startDragGesture() -> DragInfo? {
            guard
                let tappedAnnotation = tappedAnnotation(on: pageView),
                tappedAnnotation.isEditable,
                let annotationClone = tappedAnnotation.createCloneImage(frame: annotationFrame(tappedAnnotation, on: pageView), addTo: pageView)
            else {
                gestureRecognizer.cancel()
                return nil
            }

            removeExistingAnnotationSelections()
            let tapLocationInAnnotationClone = tapLocationInAnnotationClone(annotationClone)
            hideAnnotation(tappedAnnotation)
            return DragInfo(dragPointWithinAnnotation: tapLocationInAnnotationClone, draggedAnnotation: tappedAnnotation, annotationClone: annotationClone, pageView: pageView)
        }

        private func removeExistingAnnotationSelections() {
            pdf.selectedAnnotations = []
        }

        private func tappedAnnotation(on pageView: PDFPageView) -> Annotation? {
            let movableAnnotations = pdf.document.movableAnnotations(on: pageView.pageIndex)
            let tapLocationInPDFCoordinates = tapLocationInPDFCoordinates
            return movableAnnotations.first { $0.hitTest(tapLocationInPDFCoordinates, minDiameter: 30) }
        }

        private var tapLocationInPDFCoordinates: CGPoint {
            let tapPointInPageView = gestureRecognizer.location(in: pageView)
            let tapPointInPdf = pageView.convert(tapPointInPageView, to: pageView.pdfCoordinateSpace)
            return tapPointInPdf
        }

        /** In the page view's coordinates. */
        private func annotationFrame(_ annotation: Annotation, on pageView: PDFPageView) -> CGRect {
            pageView.convert(annotation.boundingBox, from: pageView.pdfCoordinateSpace)
        }

        private func tapLocationInAnnotationClone(_ annotationClone: UIImageView) -> CGPoint {
            let tapLocationInGestureView = gestureRecognizer.location(in: pageView)
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
