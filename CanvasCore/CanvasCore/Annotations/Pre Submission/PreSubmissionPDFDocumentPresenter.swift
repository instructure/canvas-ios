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
    @objc var pdfDocument: PSPDFDocument
    @objc let session: Session?
    @objc let defaultCourseID: String?
    @objc let defaultAssignmentID: String?
    @objc open var didSaveAnnotations: ()->Void = { }
    @objc open var didSubmitAssignment: ()->Void = { }

    @objc public init(documentURL: URL, session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) {
        pdfDocument = PSPDFDocument(url: documentURL)
        pdfDocument.annotationSaveMode = .embedded
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        super.init()
        pdfDocument.delegate = self
    }

    @objc func configuration(forSession session: Session?) -> PSPDFConfiguration {
        return PSPDFConfiguration { (builder) -> Void in
            applySharedAppConfiguration(to: builder)
            if let session = session {
                let submitActivity = SubmitAssignmentActivity(session: session,
                                                              defaultCourseID: self.defaultCourseID,
                                                              defaultAssignmentID: self.defaultAssignmentID,
                                                              assignmentSubmitted: self.didSubmitAssignment)
                let sharing = PSPDFDocumentSharingConfiguration { builder in
                    builder.annotationOptions = [.embed]
                    builder.applicationActivities += [UIActivity.ActivityType.PSPDFActivityTypeOpenIn, submitActivity]
                }
                builder.sharingConfigurations = [sharing]
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
                builder.propertiesForAnnotations[.ink] = [["color"], ["lineWidth"]]
                builder.propertiesForAnnotations[.square] = [["color"], ["lineWidth"]]
                builder.propertiesForAnnotations[.circle] = [["color"], ["lineWidth"]]
                builder.propertiesForAnnotations[.line] = [["color"], ["lineWidth"]]
                builder.propertiesForAnnotations[.polygon] = [["color"], ["lineWidth"]]

                // Override the override
                builder.overrideClass(PSPDFAnnotationToolbar.self, with: PSPDFAnnotationToolbar.self)
            }
        }
    }

    @objc func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance.styleManager
        styleManager.setupDefaultStylesIfNeeded()
    }

    @objc open func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration(forSession: session))
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.annotationButtonItem, pdfViewController.searchButtonItem]
        pdfViewController.annotationToolbarController?.toolbar.supportedToolbarPositions = [.positionLeft, .positionInTopBar, .positionsVertical,  .positionRight]
        pdfViewController.annotationToolbarController?.toolbar.toolbarPosition = .positionLeft
        pdfViewController.delegate = self

        return pdfViewController
    }
    
    @objc public func savePDFAnnotations() {
        try? pdfDocument.save()
    }
    
}

extension PreSubmissionPDFDocumentPresenter: PSPDFViewControllerDelegate {
    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        return menuItems
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [PSPDFAnnotation]?, in annotationRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if annotations?.count == 1, let annotation = annotations?.first {
            var realMenuItems = [PSPDFMenuItem]()
            let filteredMenuItems = menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == PSPDFTextMenu.annotationMenuInspector.rawValue {
                    $0.title = NSLocalizedString("Style", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                }
                return (
                    identifier != PSPDFTextMenu.annotationMenuRemove.rawValue &&
                    identifier != PSPDFTextMenu.annotationMenuNote.rawValue
                )
            }
            realMenuItems.append(contentsOf: filteredMenuItems)
            realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Remove", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), image: .icon(.trash), block: {
                pdfController.document?.remove([annotation], options: nil)
            }, identifier: PSPDFTextMenu.annotationMenuRemove.rawValue))
            return realMenuItems
        }

        return menuItems
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if controller is PSPDFStampViewController {
            return false
        }

        if controller is UIActivityViewController {
            // If presenting the share sheet, save the annotations!
            // PSPDFKit was not doing this @ version 5.5
            _ = try? pdfDocument.save()
        }

        return true
    }
}

extension PreSubmissionPDFDocumentPresenter: PSPDFDocumentDelegate {
    @objc public func pdfDocument(_ document: PSPDFDocument, didSave annotations: [PSPDFAnnotation]) {
        didSaveAnnotations()
    }
}
