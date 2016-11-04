
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import PSPDFKit
import TooLegit
import AssignmentKit

public class PreSubmissionPDFDocumentPresenter: NSObject {
    var pdfDocument: PSPDFDocument
    let session: Session?
    let defaultCourseID: String?
    let defaultAssignmentID: String?
    public var didSaveAnnotations: (Void)->Void = { }
    public var didSubmitAssignment: (Void)->Void = { }

    public init(documentURL: NSURL, session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) {
        pdfDocument = PSPDFDocument(URL: documentURL)
        pdfDocument.annotationSaveMode = .Embedded
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        super.init()
        pdfDocument.delegate = self
    }

    func configuration(forSession session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) -> PSPDFConfiguration {
        return PSPDFConfiguration { (builder) -> Void in
            builder.shouldAskForAnnotationUsername = false
            builder.pageTransition = PSPDFPageTransition.ScrollContinuous
            builder.scrollDirection = PSPDFScrollDirection.Vertical
            builder.thumbnailBarMode = PSPDFThumbnailBarMode.None
            builder.fitToWidthEnabled = true
            builder.pagePadding = 5.0
            builder.documentLabelEnabled = .NO
            builder.renderAnimationEnabled = false
            builder.shouldHideNavigationBarWithHUD = false
            builder.shouldHideStatusBarWithHUD = false
            builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
            builder.editableAnnotationTypes = [
                PSPDFAnnotationStringLink,
                PSPDFAnnotationStringHighlight,
                PSPDFAnnotationStringUnderline,
                PSPDFAnnotationStringStrikeOut,
                PSPDFAnnotationStringSquiggly,
                PSPDFAnnotationStringFreeText,
                PSPDFAnnotationStringInk,
                PSPDFAnnotationStringSquare,
                PSPDFAnnotationStringCircle,
                PSPDFAnnotationStringLine,
                PSPDFAnnotationStringPolygon,
                PSPDFAnnotationStringEraser
            ]

            if let session = session {
                builder.applicationActivities = [SubmitAssignmentActivity(session: session, defaultCourseID: self.defaultCourseID, defaultAssignmentID: self.defaultAssignmentID, assignmentSubmitted: self.didSubmitAssignment)] + builder.applicationActivities
            }
        }
    }

    func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance().styleManager
        styleManager.setupDefaultStylesIfNeeded()
    }

    public func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration(forSession: session))
        pdfViewController.annotationStateManager.addDelegate(self)
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.annotationButtonItem]
        pdfViewController.delegate = self

        return pdfViewController
    }
}

extension PreSubmissionPDFDocumentPresenter: PSPDFAnnotationStateManagerDelegate {
    public func annotationStateManager(manager: PSPDFAnnotationStateManager, didChangeState state: String?, to newState: String?, variant: String?, to newVariant: String?) {
        if newState == PSPDFAnnotationStringInk && newVariant == PSPDFAnnotationStringInkVariantPen {
            for (_, drawView) in manager.drawViews {
                drawView.combineInk = false
                drawView.naturalDrawingEnabled = false
            }
        }
    }
}

extension PreSubmissionPDFDocumentPresenter: PSPDFViewControllerDelegate {
    public func pdfViewController(pdfController: PSPDFViewController, shouldShowController controller: UIViewController, options: [String : AnyObject]?, animated: Bool) -> Bool {
        if controller is UIActivityViewController {
            // If presenting the share sheet, save the annotations!
            // PSPDFKit was not doing this @ version 5.5
            _ = try? pdfDocument.saveAnnotations()
        }

        // Intercept and customize the document sharing view controller.
        if let sharingController = controller as? PSPDFDocumentSharingViewController {
            sharingController.selectedOptions = [.AllPages, .EmbedAnnotations]
        }

        return true
    }
}

extension PreSubmissionPDFDocumentPresenter: PSPDFDocumentDelegate {
    public func pdfDocument(document: PSPDFDocument, didSaveAnnotations annotations: [PSPDFAnnotation]) {
        didSaveAnnotations()
    }
}
