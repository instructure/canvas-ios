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

let DisabledMenuItems: [String] = [
    TextMenu.annotationMenuOpacity.rawValue,
    TextMenu.annotationMenuThickness.rawValue,
]

// This class will be the manager for the PSPDFViewController. Any app that wants to display this document will have to:
// 1. Decide between Crocodoc or Native.
// IF NATIVE:
// 2. Use the CanvadocsAnnotationService to pull the metadata, the document, and the annotations
// 3. Instantiate this class, injecting the necessary stuff
// 4. Insert the resulting view controller from `getPDFViewController` into the view hierarchy wherever you want

open class CanvadocsPDFDocumentPresenter: NSObject {
    @objc var pdfDocument: Document
    @objc let configuration: PDFConfiguration
    @objc var onSaveStateChange: RCTDirectEventBlock?
    
    @objc var localPDFURL: URL
    var annotations: [CanvadocsAnnotation]
    var metadata: CanvadocsFileMetadata?
    @objc let service: CanvadocsAnnotationService
    @objc var annotationProvider: CanvadocsAnnotationProvider?
    @objc weak var pdfViewController: PDFViewController?

    @objc public static func loadPDFViewController(_ sessionURL: URL, with configuration: PDFConfiguration, showAnnotationBarButton: Bool, onSaveStateChange: RCTDirectEventBlock? = nil, completed: @escaping (UIViewController?, [NSError]?)->()) {
        var metadata: CanvadocsFileMetadata? = nil
        var localPDFURL: URL? = nil
        var canvadocsAnnotations: [CanvadocsAnnotation]? = nil

        let loadGroup = DispatchGroup()
        let canvadocsAnnotationService = CanvadocsAnnotationService(sessionURL: sessionURL)

        var errors: [NSError] = []

        loadGroup.enter()
        canvadocsAnnotationService.getMetadata { result in
            switch result {
            case .failure(let error):
                errors.append(error)
                loadGroup.leave()
            case .success(let metadataValue):
                metadata = metadataValue
                canvadocsAnnotationService.metadata = metadata

                loadGroup.enter()
                canvadocsAnnotationService.getDocument() { result in
                    switch result {
                    case .failure(let error):
                        errors.append(error)
                    case .success(let value):
                        localPDFURL = value
                    }
                    loadGroup.leave()
                }

                if metadataValue.annotationMetadata.enabled {
                    loadGroup.enter()
                    canvadocsAnnotationService.getAnnotations() { result in
                        switch result {
                        case .failure(let error):
                            errors.append(error)
                        case .success(let annotations):
                            canvadocsAnnotations = annotations
                        }
                        loadGroup.leave()
                    }
                } else {
                    canvadocsAnnotations = []
                }
                loadGroup.leave()
            }
        }
        
        loadGroup.notify(queue: DispatchQueue.main) {
            if errors.count > 0 {
                completed(nil, errors)
            }

            if let localPDFURL = localPDFURL, let annotations = canvadocsAnnotations, let metadata = metadata {
                canvadocsAnnotationService.metadata = metadata
                let documentPresenter = CanvadocsPDFDocumentPresenter(localPDFURL: localPDFURL, annotations: annotations, metadata: metadata, service: canvadocsAnnotationService, configuration: configuration)
                documentPresenter.onSaveStateChange = onSaveStateChange
                let pdfViewController = documentPresenter.getPDFViewController(showAnnotationBarButton: showAnnotationBarButton)
                completed(pdfViewController, nil)
            }
        }
    }

    init(localPDFURL: URL, annotations: [CanvadocsAnnotation], metadata: CanvadocsFileMetadata? = nil, service: CanvadocsAnnotationService, configuration: PDFConfiguration) {
        self.localPDFURL = localPDFURL
        self.annotations = annotations
        self.metadata = metadata
        self.service = service
        self.pdfDocument = Document(url: localPDFURL)
        self.configuration = configuration
        super.init()

        if let metadata = metadata {
            pdfDocument.defaultAnnotationUsername = metadata.annotationMetadata.userName
        }
        pdfDocument.didCreateDocumentProviderBlock = { documentProvider in
            let canvadocsAnnotationProvider = CanvadocsAnnotationProvider(documentProvider: documentProvider, annotations: annotations, service: service)
            canvadocsAnnotationProvider.canvasDelegate = self
            documentProvider.annotationManager.annotationProviders.insert(canvadocsAnnotationProvider, at: 0)
            self.annotationProvider = canvadocsAnnotationProvider
            if let metadata = self.metadata {
                for (pageKey, rawRotation) in metadata.rotations {
                    if let pageIndex = PageIndex(pageKey), let rotation = Rotation(rawValue: rawRotation) {
                        documentProvider.setRotationOffset(rotation, forPageAt: pageIndex)
                    }
                }
            }
        }
    }

    @objc open func getPDFViewController(showAnnotationBarButton: Bool = true) -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PDFViewController(document: pdfDocument, configuration: configuration)
        pdfViewController.delegate = self
        
        var buttonItems = [UIBarButtonItem] ()
        buttonItems.append(pdfViewController.activityButtonItem)
        buttonItems.append(pdfViewController.searchButtonItem)
        if showAnnotationBarButton {
            buttonItems.append(pdfViewController.annotationButtonItem)
        }
        
        pdfViewController.navigationItem.rightBarButtonItems = buttonItems
        self.pdfViewController = pdfViewController

        return pdfViewController
    }
}

extension CanvadocsPDFDocumentPresenter: PDFViewControllerDelegate {
    
    public func pdfViewController(_ pdfController: PDFViewController, shouldShow menuItems: [MenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PDFPageView) -> [MenuItem] {
        return menuItems
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow menuItems: [MenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [Annotation]?, in annotationRect: CGRect, on pageView: PDFPageView) -> [MenuItem] {
        annotations?.forEach { (pageView.annotationView(for: $0) as? FreeTextAnnotationView)?.resizableView?.allowRotating = false }
        if annotations?.count == 1, let annotation = annotations?.first, let metadata = service.metadata?.annotationMetadata {
            var realMenuItems = [MenuItem]()
            realMenuItems.append(MenuItem(title: NSLocalizedString("Comments", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), block: {
                if let pdfDocument = pdfController.document {
                    let commentsVC = CanvadocsCommentsViewController.new(annotation, pdfDocument: pdfDocument, metadata: metadata)
                    commentsVC.comments = self.annotationProvider?.getReplies(to: annotation) ?? []
                    let navigationController = UINavigationController(rootViewController: commentsVC)
                    pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                }
            }))

            let filteredMenuItems = menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == TextMenu.annotationMenuInspector.rawValue {
                    $0.title = NSLocalizedString("Style", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                }
                return (
                    identifier != TextMenu.annotationMenuRemove.rawValue &&
                    identifier != TextMenu.annotationMenuCopy.rawValue &&
                    identifier != TextMenu.annotationMenuNote.rawValue &&
                    !DisabledMenuItems.contains(identifier)
                )
            }
            realMenuItems.append(contentsOf: filteredMenuItems)

            if annotation.isEditable || metadata.permissions == .ReadWriteManage {
                realMenuItems.append(MenuItem(title: NSLocalizedString("Remove", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), image: .icon(.trash), block: {
                    pdfController.document?.remove(annotations: [annotation], options: nil)
                }, identifier: TextMenu.annotationMenuRemove.rawValue))
            }
            return realMenuItems
        }

        //  disable long press menu, which was causing another toolbar to be displayed
        if annotations == nil || annotations?.isEmpty == true {
            return []
        }


        return menuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !DisabledMenuItems.contains(identifier)
        }
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if controller is StampViewController {
            return false
        }
        return true
    }
    
    public func pdfViewController(_ pdfController: PDFViewController, didTapOn pageView: PDFPageView, at viewPoint: CGPoint) -> Bool {
        let state = pdfController.annotationStateManager
        if state.state == .stamp, let pdfDocument = pdfController.document, let metadata = service.metadata?.annotationMetadata {
            let pointAnnotation = CanvadocsPointAnnotation()
            pointAnnotation.user = metadata.userID
            pointAnnotation.userName = metadata.userName
            pointAnnotation.color = state.drawColor
            pointAnnotation.boundingBox = CGRect(x: 0, y: 0, width: 9.33, height: 13.33)
            pointAnnotation.pageIndex = pageView.pageIndex
            pageView.center(pointAnnotation, aroundPDFPoint: pageView.convert(viewPoint, to: pageView.pdfCoordinateSpace))
            pdfDocument.add(annotations: [ pointAnnotation ], options: nil)

            let commentsVC = CanvadocsCommentsViewController.new(pointAnnotation, pdfDocument: pdfDocument, metadata: metadata)
            let navigationController = UINavigationController(rootViewController: commentsVC)
            pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)

            return true
        }
        return false
    }
}

extension CanvadocsPDFDocumentPresenter: CanvadocsAnnotationProviderDelegate {
    func annotationDidExceedLimit(annotation: CanvadocsAnnotation) {
        guard let pdfViewController = pdfViewController else { return }
        switch annotation.type {
        case .ink where pdfViewController.annotationStateManager.state == .ink:
            let variant = pdfViewController.annotationStateManager.variant
            self.pdfViewController?.annotationStateManager.toggleState(.ink, variant: variant)
            self.pdfViewController?.annotationStateManager.toggleState(.ink, variant: variant)
        default:
            break
        }
    }
    
    @objc func annotationDidFailToSave(error: NSError) {
        self.onSaveStateChange?(["error": error.localizedDescription])
    }
    
    @objc func annotationSaveStateChanges(saving: Bool) {
        self.onSaveStateChange?(["saving": saving])
    }
}
