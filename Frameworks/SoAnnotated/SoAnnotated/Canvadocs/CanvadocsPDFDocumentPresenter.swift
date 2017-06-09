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
    var localXFDFURL: URL
    var metadata: CanvadocsFileMetadata?
    let service: CanvadocsAnnotationService?
    var annotationProvider: CanvadocsAnnotationProvider?

    open static func loadPDFViewController(_ sessionURL: URL, with configuration: PSPDFConfiguration, completed: @escaping (UIViewController?, [NSError]?)->()) {
        var metadata: CanvadocsFileMetadata? = nil
        var localPDFURL: URL? = nil
        var localXFDFURL: URL? = nil

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

                loadGroup.enter()
                canvadocsAnnotationService.getAnnotations() { result in
                    switch result {
                    case .failure(let error):
                        errors.append(error)
                    case .success(let value):
                        localXFDFURL = value
                    }
                    loadGroup.leave()
                }

                loadGroup.leave()
            }
        }

        loadGroup.notify(queue: DispatchQueue.main) {
            if errors.count > 0 {
                completed(nil, errors)
            }

            if let localPDFURL = localPDFURL, let localXFDFURL = localXFDFURL, let metadata = metadata {
                canvadocsAnnotationService.metadata = metadata
                let documentPresenter = CanvadocsPDFDocumentPresenter(localPDFURL: localPDFURL, localXFDFURL: localXFDFURL, metadata: metadata, service: canvadocsAnnotationService, configuration: configuration)
                let pdfViewController = documentPresenter.getPDFViewController()
                completed(pdfViewController, nil)
            }
        }
    }

    init(localPDFURL: URL, localXFDFURL: URL, metadata: CanvadocsFileMetadata? = nil, service: CanvadocsAnnotationService? = nil, configuration: PSPDFConfiguration) {
        self.localPDFURL = localPDFURL
        self.localXFDFURL = localXFDFURL
        self.metadata = metadata
        self.service = service
        self.pdfDocument = PSPDFDocument(url: localPDFURL)
        self.configuration = configuration
        super.init()

        if let metadata = metadata {
            pdfDocument.defaultAnnotationUsername = metadata.annotationMetadata.userName
        }
        if let service = service {
            pdfDocument.didCreateDocumentProviderBlock = { documentProvider in
                let canvadocsAnnotationProvider = CanvadocsAnnotationProvider(documentProvider: documentProvider, fileURL: self.localXFDFURL, service: service)
                documentProvider.annotationManager.annotationProviders = [canvadocsAnnotationProvider]
                self.annotationProvider = canvadocsAnnotationProvider
            }
        } else {
            pdfDocument.didCreateDocumentProviderBlock = { documentProvider in
                let annotationProvider = PSPDFXFDFAnnotationProvider(documentProvider: documentProvider, fileURL: localXFDFURL)
                let fileProvider = PSPDFFileAnnotationProvider(documentProvider: documentProvider)
                documentProvider.annotationManager.annotationProviders = [annotationProvider, fileProvider]
            }
            pdfDocument.annotationSaveMode = .embedded
        }
    }

    func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance.styleManager
        styleManager.setupDefaultStylesIfNeeded()

        let highlightPresets = highlightCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        let inkPresets = standardCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        styleManager.setPresets(highlightPresets, forKey: .highlight, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen), type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .square, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .circle, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .line, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets([PSPDFColorPreset(color: canvadocsAnnotationRedColor)], forKey: .strikeOut, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: .freeText, type: PSPDFStyleManagerColorPresetKey)

        styleManager.setLastUsedValue(canvadocsHighlightAnnotationYellowColor, forProperty: "color", forKey: .highlight)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen))
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: .square)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: .circle)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: .line)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: .strikeOut)
        styleManager.setLastUsedValue(canvadocsAnnotationBlackColor, forProperty: "color", forKey: .freeText)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStateVariantIdentifier(.ink, .inkVariantPen))
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: .square)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: .circle)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: .line)
    }

    open func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration)
        pdfViewController.delegate = self
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.searchButtonItem, pdfViewController.annotationButtonItem]

        let highlightGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: .highlight)])
        let strikeoutGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: .strikeOut)])
        let freeTextGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: .freeText)])
        let commentGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: .note)])
        let inkGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: .ink, variant: .inkVariantPen, configurationBlock: PSPDFAnnotationGroupItem.inkConfigurationBlock()), PSPDFAnnotationGroupItem(type: .square), PSPDFAnnotationGroupItem(type: .circle), PSPDFAnnotationGroupItem(type: .line)])
        pdfViewController.annotationToolbarController?.annotationToolbar.configurations = [PSPDFAnnotationToolbarConfiguration(annotationGroups: [commentGroup, inkGroup, highlightGroup, freeTextGroup, strikeoutGroup])]

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

                for menuItem in menuItems {
                    if menuItem.identifier != PSPDFAnnotationMenuCopy && menuItem.identifier != PSPDFAnnotationMenuNote {
                        realMenuItems.append(menuItem)
                    }
                }
                return realMenuItems
            } else if firstAnnotation.type == PSPDFAnnotationType.ink || firstAnnotation.type == PSPDFAnnotationType.circle || firstAnnotation.type == PSPDFAnnotationType.line || firstAnnotation.type == PSPDFAnnotationType.strikeOut {
                var realMenuItems = [PSPDFMenuItem]()
                for menuItem in menuItems {
                    if menuItem.identifier != PSPDFAnnotationMenuNote {
                        realMenuItems.append(menuItem)
                    }
                }
                return realMenuItems
            }
        }

        return menuItems
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
