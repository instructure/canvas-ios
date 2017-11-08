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

let DisabledMenuItems: [String] = [
    PSPDFAnnotationMenuOpacity,
    PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationString.ink, PSPDFAnnotationString.inkVariantPen).rawValue,
    PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationString.ink, PSPDFAnnotationString.inkVariantHighlighter).rawValue,
]

// This class will be the manager for the PSPDFViewController. Any app that wants to display this document will have to:
// 1. Decide between Crocodoc or Native.
// IF NATIVE:
// 2. Use the CanvadocsAnnotationService to pull the metadata, the document, and the annotations
// 3. Instantiate this class, injecting the necessary stuff
// 4. Insert the resulting view controller from `getPDFViewController` into the view heirarchy wherever you want

open class CanvadocsPDFDocumentPresenter: NSObject {
    var pdfDocument: PSPDFDocument
    let configuration: PSPDFConfiguration

    var localPDFURL: URL
    var annotations: [CanvadocsAnnotation]
    var metadata: CanvadocsFileMetadata?
    let service: CanvadocsAnnotationService
    var annotationProvider: CanvadocsAnnotationProvider?
    weak var pdfViewController: PSPDFViewController?

    open static func loadPDFViewController(_ sessionURL: URL, with configuration: PSPDFConfiguration, completed: @escaping (UIViewController?, [NSError]?)->()) {
        var metadata: CanvadocsFileMetadata? = nil
        var localPDFURL: URL? = nil
        var canvadocsAnnotations: [CanvadocsAnnotation]? = nil

        let loadGroup = DispatchGroup();
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
                        print("ANNOTATIONS RESULT: \(result)")
                        switch result {
                        case .failure(let error):
                            print("FAILED GETTING ANNOTATIONS: \(error)")
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
                let pdfViewController = documentPresenter.getPDFViewController()
                completed(pdfViewController, nil)
            }
        }
    }

    init(localPDFURL: URL, annotations: [CanvadocsAnnotation], metadata: CanvadocsFileMetadata? = nil, service: CanvadocsAnnotationService, configuration: PSPDFConfiguration) {
        self.localPDFURL = localPDFURL
        self.annotations = annotations
        self.metadata = metadata
        self.service = service
        self.pdfDocument = PSPDFDocument(url: localPDFURL)
        self.configuration = configuration
        super.init()

        if let metadata = metadata {
            pdfDocument.defaultAnnotationUsername = metadata.annotationMetadata.userName
        }
        pdfDocument.didCreateDocumentProviderBlock = { documentProvider in
            let canvadocsAnnotationProvider = CanvadocsAnnotationProvider(documentProvider: documentProvider, annotations: annotations, service: service)
            canvadocsAnnotationProvider.delegate = self
            documentProvider.annotationManager.annotationProviders = [canvadocsAnnotationProvider]
            self.annotationProvider = canvadocsAnnotationProvider
        }
    }

    func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance.styleManager
        styleManager.setupDefaultStylesIfNeeded()

        let highlightPresets = highlightCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        let inkPresets = standardCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        let textPresets = standardCanvadocsColors.map { return PSPDFColorPreset(color: $0, fill: .white, alpha: 1) }
        styleManager.setPresets(highlightPresets, forKey: .highlight, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen), type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .square, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .circle, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .line, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .strikeOut, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .note, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(textPresets, forKey: .freeText, type: PSPDFStyleManagerColorPresetKey)

        styleManager.setLastUsedValue(CanvadocsHighlightColor.yellow.color, forProperty: "color", forKey: .highlight)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen))
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .square)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .circle)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .line)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .strikeOut)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.blue.color, forProperty: "fillColor", forKey: .note)
        styleManager.setLastUsedValue(UIColor.black, forProperty: "color", forKey: .freeText)
        styleManager.setLastUsedValue(UIColor.white, forProperty: "fillColor", forKey: .freeText)
        styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen))
        styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: .square)
        styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: .circle)
        styleManager.setLastUsedValue(2.0, forProperty: "lineWidth", forKey: .line)
    }

    open func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration)
        pdfViewController.delegate = self
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.searchButtonItem, pdfViewController.annotationButtonItem]
        self.pdfViewController = pdfViewController

        return pdfViewController
    }
}

extension CanvadocsPDFDocumentPresenter: PSPDFViewControllerDelegate {
    
    // Adds a "Create Note" menu item from selected text
    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if selectedText.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            let createNoteMenuItem = PSPDFMenuItem(title: NSLocalizedString("Create Note", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Button for creating a note from text selection"), block: {
                let templateAnnotation = PSPDFNoteAnnotation(contents: "")
                templateAnnotation.boundingBox = CGRect(x: textRect.maxX, y: textRect.origin.y, width: 32.0, height: 32.0)
                templateAnnotation.pageIndex = pageView.pageIndex
                pageView.selectionView.discardSelection(animated: false)

                if let pdfDocument = pdfController.document { // *should* always be this type
                    let commentsVC = CanvadocsCommentsViewController.new(pdfDocument: pdfDocument)
                    commentsVC.templateAnnotation = templateAnnotation
                    let navigationController = UINavigationController(rootViewController: commentsVC)
                    pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                }
            })
            return menuItems + [createNoteMenuItem]
        } else {
            return menuItems
        }
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [PSPDFAnnotation]?, in annotationRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if let firstAnnotation = annotations?.first {
            if firstAnnotation.type == PSPDFAnnotationType.note && annotations?.count == 1 {
                var realMenuItems = [PSPDFMenuItem]()
                realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Note...", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), block: {
                    if let pdfDocument = pdfController.document {
                        let commentsVC = CanvadocsCommentsViewController.new(firstAnnotation, pdfDocument: pdfDocument)
                        commentsVC.comments = [firstAnnotation] + ((self.annotationProvider?.childrenMapping[firstAnnotation.name!] ?? []) as [PSPDFAnnotation])
                        let navigationController = UINavigationController(rootViewController: commentsVC)
                        pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                    }
                }))

                let filteredMenuItems = menuItems.filter {
                    guard let identifier = $0.identifier else { return true }
                    return identifier != PSPDFAnnotationMenuCopy && identifier != PSPDFAnnotationMenuNote && !DisabledMenuItems.contains(identifier)
                }
                realMenuItems.append(contentsOf: filteredMenuItems)
                return realMenuItems
            }
        }

        return menuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !DisabledMenuItems.contains(identifier)
        }
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if let noteController = controller as? PSPDFNoteAnnotationViewController, let annotation = noteController.annotation, let pdfDocument = pdfController.document {
            var rootAnnotation: PSPDFAnnotation? = annotation
            var comments: [PSPDFAnnotation] = []
            if let contents = annotation.contents {
                // If this is a brand spanking new note
                if contents == "" && annotation.type == PSPDFAnnotationType.note {
                    rootAnnotation = nil
                } else if contents != "" { // If this has something and isn't a note type
                    comments = [annotation] + ((self.annotationProvider?.childrenMapping[annotation.name!] ?? []) as [PSPDFAnnotation])
                }
            }
            let commentsVC = CanvadocsCommentsViewController.new(rootAnnotation, pdfDocument: pdfDocument)
            commentsVC.comments = comments
            commentsVC.templateAnnotation = annotation
            let navigationController = UINavigationController(rootViewController: commentsVC)
            pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)

            return false
        }

        return true
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
}
