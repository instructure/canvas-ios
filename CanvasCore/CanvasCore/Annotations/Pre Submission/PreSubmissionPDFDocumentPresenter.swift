//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import PSPDFKit
import PSPDFKitUI
open class PreSubmissionPDFDocumentPresenter: NSObject {
    var pdfDocument: PSPDFDocument
    let session: Session?
    let defaultCourseID: String?
    let defaultAssignmentID: String?
    open var didSaveAnnotations: ()->Void = { }
    open var didSubmitAssignment: ()->Void = { }

    public init(documentURL: URL, session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) {
        pdfDocument = PSPDFDocument(url: documentURL)
        pdfDocument.annotationSaveMode = .embedded
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        super.init()
        pdfDocument.delegate = self
    }

    func configuration(forSession session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) -> PSPDFConfiguration {
        return PSPDFConfiguration { (builder) -> Void in
            builder.shouldAskForAnnotationUsername = false
            builder.pageTransition = PSPDFPageTransition.scrollContinuous
            builder.scrollDirection = PSPDFScrollDirection.vertical
            builder.thumbnailBarMode = PSPDFThumbnailBarMode.none
            builder.spreadFitting = .fill
            builder.additionalScrollViewFrameInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            builder.pageMode = .single
            builder.documentLabelEnabled = .NO
            builder.isRenderAnimationEnabled = false
            builder.shouldHideNavigationBarWithUserInterface = false
            builder.shouldHideStatusBarWithUserInterface = false
            builder.naturalDrawingAnnotationEnabled = true
            builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
            builder.editableAnnotationTypes = [
                .link,
                .highlight,
                .underline,
                .strikeOut,
                .squiggly,
                .freeText,
                .ink,
                .square,
                .circle,
                .line,
                .polygon,
                .eraser
            ]

            if let session = session {
                builder.applicationActivities = [SubmitAssignmentActivity(session: session, defaultCourseID: self.defaultCourseID, defaultAssignmentID: self.defaultAssignmentID, assignmentSubmitted: self.didSubmitAssignment)] + builder.applicationActivities
            }
        }
    }

    func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance.styleManager
        styleManager.setupDefaultStylesIfNeeded()
    }

    open func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration(forSession: session))
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.annotationButtonItem]
        pdfViewController.delegate = self

        return pdfViewController
    }
    
    public func savePDFAnnotations() {
        try? pdfDocument.save()
    }
    
}

extension PreSubmissionPDFDocumentPresenter: PSPDFViewControllerDelegate {
    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if controller is UIActivityViewController {
            // If presenting the share sheet, save the annotations!
            // PSPDFKit was not doing this @ version 5.5
            _ = try? pdfDocument.save()
        }

        // Intercept and customize the document sharing view controller.
        if let sharingController = controller as? PSPDFDocumentSharingViewController {
            sharingController.selectedOptions = [.allPages, .embedAnnotations]
        }

        return true
    }
}

extension PreSubmissionPDFDocumentPresenter: PSPDFDocumentDelegate {
    public func pdfDocument(_ document: PSPDFDocument, didSave annotations: [PSPDFAnnotation]) {
        didSaveAnnotations()
    }
}
