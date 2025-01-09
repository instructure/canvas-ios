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

import UIKit
import PSPDFKit
import PSPDFKitUI

class AnnotationDragGestureViewModel {
    public var isEnabled: Bool = false {
        didSet {
            gestureRecognizer.isEnabled = isEnabled
        }
    }
    private let pdf: PDFViewController
    private let gestureRecognizer: UIGestureRecognizer
    private var dragInfo: DragInfo?
    private let dragGestureDelegate = AnnotationDragGestureDelegate()

    public init(pdf: PDFViewController, gestureRecognizer: UIGestureRecognizer) {
        self.pdf = pdf
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.addTarget(self, action: #selector(dragStateChanged))
        gestureRecognizer.isEnabled = false
        gestureRecognizer.delegate = dragGestureDelegate
    }

    @objc private func dragStateChanged() {
        guard let documentViewController = pdf.documentViewController else { return }

        switch gestureRecognizer.state {
        case .began:
            let startViewModel = DragStartViewModel(pdf: pdf, documentViewController: documentViewController, gestureRecognizer: gestureRecognizer)
            dragInfo = startViewModel?.startDragGesture()
        case .changed:
            updateAnnotationClonePosition()
        case .cancelled, .ended, .failed:
            finalizeAnnotationPositionAndRemoveClone(documentViewController: documentViewController)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    private func updateAnnotationClonePosition() {
        guard let dragInfo = dragInfo else { return }

        let tapPointInView = gestureRecognizer.location(in: dragInfo.pageView)
        var annotationImageFrame = dragInfo.annotationClone.frame
        annotationImageFrame.origin = CGPoint(x: tapPointInView.x - dragInfo.dragPointWithinAnnotation.x, y: tapPointInView.y - dragInfo.dragPointWithinAnnotation.y)
        dragInfo.annotationClone.frame = annotationImageFrame
        dragInfo.annotationClone.restrictFrameInsideSuperview()
    }

    private func finalizeAnnotationPositionAndRemoveClone(documentViewController: PDFDocumentViewController) {
        guard let dragInfo = dragInfo, let cloneContainerView = dragInfo.annotationClone.superview else { return }
        let annotationPositionInDocumentView = cloneContainerView.convert(dragInfo.annotationClone.center, to: documentViewController.view)
        guard let pageView = documentViewController.visiblePageView(at: annotationPositionInDocumentView) else { return }

        let newBoundingBoxInPageView = dragInfo.annotationClone.frame
        let newBoundingBoxInPdf = pageView.convert(newBoundingBoxInPageView, to: pageView.pdfCoordinateSpace)
        dragInfo.draggedAnnotation.boundingBox = newBoundingBoxInPdf
        dragInfo.draggedAnnotation.flags.remove(.hidden)

        NotificationCenter.default.post(name: .PSPDFAnnotationChanged,
                                        object: dragInfo.draggedAnnotation,
                                        userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: ["flags", "boundingBox"]])
        self.dragInfo = nil
    }
}
