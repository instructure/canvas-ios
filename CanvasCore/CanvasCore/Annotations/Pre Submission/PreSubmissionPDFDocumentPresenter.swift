//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Foundation
import PSPDFKit
import PSPDFKitUI
import Core

open class PreSubmissionPDFDocumentPresenter: NSObject {
    @objc var pdfDocument: Document
    @objc let session: Session?
    @objc let defaultCourseID: String?
    @objc let defaultAssignmentID: String?
    @objc open var didSaveAnnotations: ()->Void = { }
    @objc open var didSubmitAssignment: ()->Void = { }

    @objc public init(documentURL: URL, session: Session?, defaultCourseID: String? = nil, defaultAssignmentID: String? = nil) {
        pdfDocument = Document(url: documentURL)
        pdfDocument.annotationSaveMode = .embedded
        self.session = session
        self.defaultCourseID = defaultCourseID
        self.defaultAssignmentID = defaultAssignmentID
        super.init()
        pdfDocument.delegate = self
        AppEnvironment.shared.userDefaults?.submitAssignmentCourseID = defaultCourseID
        AppEnvironment.shared.userDefaults?.submitAssignmentID = defaultAssignmentID
    }

    @objc func configuration() -> PDFConfiguration {
        return PDFConfiguration { (builder) -> Void in
            applySharedAppConfiguration(to: builder)
            let sharing = DocumentSharingConfiguration { builder in
                builder.annotationOptions = [.flatten]
                builder.pageSelectionOptions = .all
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
            builder.overrideClass(AnnotationToolbar.self, with: AnnotationToolbar.self)
        }
    }

    @objc open func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PDFViewController(document: pdfDocument, configuration: configuration())
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.annotationButtonItem, pdfViewController.searchButtonItem]
        pdfViewController.annotationToolbarController?.toolbar.supportedToolbarPositions = [.left, .inTopBar, .vertical,  .right]
        pdfViewController.annotationToolbarController?.toolbar.toolbarPosition = .left
        pdfViewController.delegate = self

        return pdfViewController
    }
    
    @objc public func savePDFAnnotations() {
        try? pdfDocument.save()
    }
    
}

extension PreSubmissionPDFDocumentPresenter: PDFViewControllerDelegate {
    public func pdfViewController(_ pdfController: PDFViewController, shouldShow menuItems: [MenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PDFPageView) -> [MenuItem] {
        return menuItems
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow menuItems: [MenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [Annotation]?, in annotationRect: CGRect, on pageView: PDFPageView) -> [MenuItem] {
        if annotations?.count == 1, let annotation = annotations?.first {
            var realMenuItems = [MenuItem]()
            let filteredMenuItems = menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == TextMenu.annotationMenuInspector.rawValue {
                    $0.title = NSLocalizedString("Style", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                }
                return (
                    identifier != TextMenu.annotationMenuRemove.rawValue &&
                    identifier != TextMenu.annotationMenuNote.rawValue
                )
            }
            realMenuItems.append(contentsOf: filteredMenuItems)
            realMenuItems.append(MenuItem(title: NSLocalizedString("Remove", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), image: .icon(.trash), block: {
                pdfController.document?.remove(annotations: [annotation], options: nil)
            }, identifier: TextMenu.annotationMenuRemove.rawValue))
            return realMenuItems
        }

        return menuItems
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if controller is StampViewController {
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

extension PreSubmissionPDFDocumentPresenter: PDFDocumentDelegate {
    @objc public func pdfDocument(_ document: Document, didSave annotations: [Annotation]) {
        didSaveAnnotations()
    }
}
