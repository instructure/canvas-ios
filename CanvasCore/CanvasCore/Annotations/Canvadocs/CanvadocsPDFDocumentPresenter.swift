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
import PSPDFKitUI

let DisabledMenuItems: [String] = [
    PSPDFAnnotationMenuOpacity,
    PSPDFAnnotationStateVariantIdentifier(AnnotationString.ink, AnnotationString.inkVariantPen).rawValue,
    PSPDFAnnotationStateVariantIdentifier(AnnotationString.ink, AnnotationString.inkVariantHighlighter).rawValue,
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
            canvadocsAnnotationProvider.limitDelegate = self
            documentProvider.annotationManager.annotationProviders.insert(canvadocsAnnotationProvider, at: 0)
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
        styleManager.setPresets(inkPresets, forKey: .stamp, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(textPresets, forKey: .freeText, type: PSPDFStyleManagerColorPresetKey)

        styleManager.setLastUsedValue(CanvadocsHighlightColor.yellow.color, forProperty: "color", forKey: .highlight)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen))
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .square)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .circle)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .line)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.red.color, forProperty: "color", forKey: .strikeOut)
        styleManager.setLastUsedValue(CanvadocsAnnotationColor.blue.color, forProperty: "color", forKey: .stamp)
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
    
    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        return menuItems
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [PSPDFAnnotation]?, in annotationRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if annotations?.count == 1, let annotation = annotations?.first {
            var realMenuItems = [PSPDFMenuItem]()
            realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Comments", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), block: {
                if let pdfDocument = pdfController.document {
                    let commentsVC = CanvadocsCommentsViewController.new(annotation, pdfDocument: pdfDocument)
                    commentsVC.comments = self.annotationProvider?.getReplies(to: annotation) ?? []
                    let navigationController = UINavigationController(rootViewController: commentsVC)
                    pdfController.present(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                }
            }))

            let filteredMenuItems = menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == PSPDFAnnotationMenuInspector {
                    $0.title = NSLocalizedString("Style", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
                }
                return identifier != PSPDFAnnotationMenuCopy && identifier != PSPDFAnnotationMenuNote && !DisabledMenuItems.contains(identifier)
            }
            realMenuItems.append(contentsOf: filteredMenuItems)
            return realMenuItems
        }

        return menuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !DisabledMenuItems.contains(identifier)
        }
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String : Any]? = nil, animated: Bool) -> Bool {
        if controller is PSPDFStampViewController {
            return false
        }
        return true
    }
    
    public func pdfViewController(_ pdfController: PSPDFViewController, didTapOn pageView: PSPDFPageView, at viewPoint: CGPoint) -> Bool {
        let state = pdfController.annotationStateManager
        if state.state == .stamp, let pdfDocument = pdfController.document {
            let pointAnnotation = CanvadocsPointAnnotation()
            pointAnnotation.color = state.drawColor
            pointAnnotation.boundingBox = CGRect(x: 0, y: 0, width: 17 * 2 / 3, height: 24 * 2 / 3)
            pointAnnotation.pageIndex = pageView.pageIndex
            pageView.center(pointAnnotation, aroundPDFPoint: pageView.convertPoint(toPDFPoint: viewPoint))
            pdfDocument.add([ pointAnnotation ], options: nil)

            let commentsVC = CanvadocsCommentsViewController.new(pointAnnotation, pdfDocument: pdfDocument)
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
}
