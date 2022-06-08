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

    public init(pdf: PDFViewController, gestureRecognizer: UIGestureRecognizer) {
        self.pdf = pdf
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.addTarget(self, action: #selector(dragStateChanged))
        gestureRecognizer.isEnabled = false
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

        let tapPointInView = gestureRecognizer.location(in: gestureRecognizer.view)
        var annotationImageFrame = dragInfo.annotationClone.frame
        annotationImageFrame.origin = CGPoint(x: tapPointInView.x - dragInfo.dragPointWithinAnnotation.x, y: tapPointInView.y - dragInfo.dragPointWithinAnnotation.y)
        dragInfo.annotationClone.frame = annotationImageFrame
    }

    private func finalizeAnnotationPositionAndRemoveClone(documentViewController: PDFDocumentViewController) {
        var isAnnotationFrameUpdated = false

        defer {
            if let draggedAnnotation = dragInfo?.draggedAnnotation {
                draggedAnnotation.flags.remove(.hidden)
                let keyPaths = ["flags"] + (isAnnotationFrameUpdated ? ["boundingBox"] : [])
                NotificationCenter.default.post(name: NSNotification.Name.PSPDFAnnotationChanged, object: draggedAnnotation, userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: keyPaths])
            }

            dragInfo = nil
        }

        guard let dragInfo = dragInfo else { return }
        guard let pageView = documentViewController.visiblePageView(at: gestureRecognizer.location(in: gestureRecognizer.view)) else { return }
        guard let gestureView = gestureRecognizer.view else { return }

        let newBoundingBoxInGestureView = dragInfo.annotationClone.frame
        let newBoundingBoxInPageView = gestureView.convert(newBoundingBoxInGestureView, to: pageView)
        let newBoundingBoxInPdf = pageView.convert(newBoundingBoxInPageView, to: pageView.pdfCoordinateSpace)

        dragInfo.draggedAnnotation.boundingBox = newBoundingBoxInPdf
        isAnnotationFrameUpdated = true
    }
}
