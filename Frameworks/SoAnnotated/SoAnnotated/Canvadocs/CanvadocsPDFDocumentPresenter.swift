//
//  CanvadocsPDFDocumentPresenter.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 7/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import PSPDFKit

// This class will be the manager for the PSPDFViewController. Any app that wants to display this document will have to:
// 1. Decide between Crocodoc or Native.
// IF NATIVE:
// 2. Use the CanvadocsAnnotationService to pull the metadata, the document, and the annotations
// 3. Instantiate this class, injecting the necessary stuff
// 4. Insert the resulting view controller from `getPDFViewController` into the view heirarchy wherever you want

public class CanvadocsPDFDocumentPresenter: NSObject {
    var pdfDocument: PSPDFDocument

    var localPDFURL: NSURL
    var localXFDFURL: NSURL
    var metadata: CanvadocsFileMetadata?
    let service: CanvadocsAnnotationService?
    var annotationProvider: CanvadocsAnnotationProvider?

    var configuration: PSPDFConfiguration = {
        return PSPDFConfiguration { (builder) -> Void in
            builder.shouldAskForAnnotationUsername = false
            builder.pageTransition = PSPDFPageTransition.ScrollContinuous
            builder.scrollDirection = PSPDFScrollDirection.Vertical
            builder.fitToWidthEnabled = true
            builder.pagePadding = 5.0
            builder.renderAnimationEnabled = false
            builder.shouldHideNavigationBarWithHUD = false
            builder.shouldHideStatusBarWithHUD = false
            builder.applicationActivities = [PSPDFActivityTypeOpenIn, PSPDFActivityTypeGoToPage, PSPDFActivityTypeSearch]
            builder.editableAnnotationTypes = [PSPDFAnnotationStringHighlight, PSPDFAnnotationStringStrikeOut, PSPDFAnnotationStringFreeText, PSPDFAnnotationStringNote, PSPDFAnnotationStringInk, PSPDFAnnotationStringSquare, PSPDFAnnotationStringCircle, PSPDFAnnotationStringLine]

            let annotationStyleProperties = [
                PSPDFAnnotationStringHighlight: [["color"]],
                PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationStringInk, PSPDFAnnotationStringInkVariantPen): [["color"]],
                PSPDFAnnotationStringSquare: [["color"]],
                PSPDFAnnotationStringCircle: [["color"]],
                PSPDFAnnotationStringLine: [["color"]],
                PSPDFAnnotationStringStrikeOut: [[]],
                PSPDFAnnotationStringFreeText: [["fontSize"]],
            ]

            builder.propertiesForAnnotations = annotationStyleProperties
        }
    }()


    public static func loadPDFViewController(sessionURL: NSURL, completed: (UIViewController?, [NSError]?)->()) {
        var metadata: CanvadocsFileMetadata? = nil
        var localPDFURL: NSURL? = nil
        var localXFDFURL: NSURL? = nil

        let loadGroup = dispatch_group_create();
        let canvadocsAnnotationService = CanvadocsAnnotationService(sessionURL: sessionURL)

        var errors: [NSError] = []

        dispatch_group_enter(loadGroup)
        canvadocsAnnotationService.getMetadata { result in
            switch result {
            case .Failure(let error):
                errors.append(error)
                dispatch_group_leave(loadGroup)
            case .Success(let metadataValue):
                metadata = metadataValue
                canvadocsAnnotationService.metadata = metadata

                dispatch_group_enter(loadGroup)
                canvadocsAnnotationService.getDocument() { result in
                    switch result {
                    case .Failure(let error):
                        errors.append(error)
                    case .Success(let value):
                        localPDFURL = value
                    }
                    dispatch_group_leave(loadGroup)
                }

                dispatch_group_enter(loadGroup)
                canvadocsAnnotationService.getAnnotations() { result in
                    switch result {
                    case .Failure(let error):
                        errors.append(error)
                    case .Success(let value):
                        localXFDFURL = value
                    }
                    dispatch_group_leave(loadGroup)
                }

                dispatch_group_leave(loadGroup)
            }
        }

        dispatch_group_notify(loadGroup, dispatch_get_main_queue()) {
            if errors.count > 0 {
                completed(nil, errors)
            }

            if let localPDFURL = localPDFURL, localXFDFURL = localXFDFURL, metadata = metadata {
                canvadocsAnnotationService.metadata = metadata
                let documentPresenter = CanvadocsPDFDocumentPresenter(localPDFURL: localPDFURL, localXFDFURL: localXFDFURL, metadata: metadata, service: canvadocsAnnotationService)
                let pdfViewController = documentPresenter.getPDFViewController()
                completed(pdfViewController, nil)
            }
        }
    }

    public convenience init(localPDFURL: NSURL, localXFDFURL: NSURL) {
        self.init(localPDFURL: localPDFURL, localXFDFURL: localXFDFURL, metadata: nil, service: nil)
    }

    init(localPDFURL: NSURL, localXFDFURL: NSURL, metadata: CanvadocsFileMetadata?, service: CanvadocsAnnotationService?) {
        self.localPDFURL = localPDFURL
        self.localXFDFURL = localXFDFURL
        self.metadata = metadata
        self.service = service
        self.pdfDocument = PSPDFDocument(URL: localPDFURL)
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
            pdfDocument.annotationSaveMode = .Embedded
        }
    }

    func stylePSPDFKit() {
        let styleManager = PSPDFKit.sharedInstance().styleManager
        styleManager.setupDefaultStylesIfNeeded()

        let highlightPresets = highlightCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        let inkPresets = standardCanvadocsColors.map { return PSPDFColorPreset(color: $0) }
        styleManager.setPresets(highlightPresets, forKey: PSPDFAnnotationStringHighlight, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationStringInk, PSPDFAnnotationStringInkVariantPen), type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStringSquare, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStringCircle, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStringLine, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets([PSPDFColorPreset(color: canvadocsAnnotationRedColor)], forKey: PSPDFAnnotationStringStrikeOut, type: PSPDFStyleManagerColorPresetKey)
        styleManager.setPresets(inkPresets, forKey: PSPDFAnnotationStringFreeText, type: PSPDFStyleManagerColorPresetKey)

        styleManager.setLastUsedValue(canvadocsHighlightAnnotationYellowColor, forProperty: "color", forKey: PSPDFAnnotationStringHighlight)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationStringInk, PSPDFAnnotationStringInkVariantPen))
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStringSquare)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStringCircle)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStringLine)
        styleManager.setLastUsedValue(canvadocsAnnotationRedColor, forProperty: "color", forKey: PSPDFAnnotationStringStrikeOut)
        styleManager.setLastUsedValue(canvadocsAnnotationBlackColor, forProperty: "color", forKey: PSPDFAnnotationStringFreeText)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStateVariantIdentifier(PSPDFAnnotationStringInk, PSPDFAnnotationStringInkVariantPen))
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStringSquare)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStringCircle)
        styleManager.setLastUsedValue(1.0, forProperty: "lineWidth", forKey: PSPDFAnnotationStringLine)
    }

    public func getPDFViewController() -> UIViewController {
        stylePSPDFKit()

        let pdfViewController = PSPDFViewController(document: pdfDocument, configuration: configuration)
        pdfViewController.delegate = self
        pdfViewController.annotationStateManager.addDelegate(self)
        pdfViewController.navigationItem.rightBarButtonItems = [pdfViewController.activityButtonItem, pdfViewController.searchButtonItem, pdfViewController.annotationButtonItem]

        let highlightGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringHighlight)])
        let strikeoutGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringStrikeOut)])
        let freeTextGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringFreeText)])
        let commentGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringNote)])
        let inkGroup = PSPDFAnnotationGroup(items: [PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringInk, variant: PSPDFAnnotationStringInkVariantPen, configurationBlock: PSPDFAnnotationGroupItem.inkConfigurationBlock()), PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringSquare), PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringCircle), PSPDFAnnotationGroupItem(type: PSPDFAnnotationStringLine)])
        pdfViewController.annotationToolbarController?.annotationToolbar.configurations = [PSPDFAnnotationToolbarConfiguration(annotationGroups: [commentGroup, inkGroup, highlightGroup, freeTextGroup, strikeoutGroup])]

        return pdfViewController
    }
}

extension CanvadocsPDFDocumentPresenter: PSPDFViewControllerDelegate {
    // Adds a "Create Note" menu item from selected text
    public func pdfViewController(pdfController: PSPDFViewController, shouldShowMenuItems menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, inRect textRect: CGRect, onPageView pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if selectedText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let createNoteMenuItem = PSPDFMenuItem(title: NSLocalizedString("Create Note", comment: "Button for creating a note from text selection"), block: {
                let templateAnnotation = PSPDFNoteAnnotation(contents: "")
                templateAnnotation.boundingBox = CGRect(x: CGRectGetMaxX(textRect), y: textRect.origin.y, width: 32.0, height: 32.0)
                templateAnnotation.page = pageView.page
                pageView.selectionView.discardSelectionAnimated(false)

                if let pdfDocument = pdfController.document { // *should* always be this type
                    let commentsVC = CanvadocsCommentsViewController.new(pdfDocument: pdfDocument)
                    commentsVC.templateAnnotation = templateAnnotation
                    let navigationController = UINavigationController(rootViewController: commentsVC)
                    pdfController.presentViewController(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                }
            })
            return menuItems + [createNoteMenuItem]
        } else {
            return menuItems
        }
    }

    public func pdfViewController(pdfController: PSPDFViewController, shouldShowMenuItems menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forAnnotations annotations: [PSPDFAnnotation]?, inRect annotationRect: CGRect, onPageView pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if let firstAnnotation = annotations?.first {
            if firstAnnotation.type == PSPDFAnnotationType.Note && annotations?.count == 1 {
                var realMenuItems = [PSPDFMenuItem]()
                realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Note...", comment: ""), block: {
                    if let pdfDocument = pdfController.document {
                        let commentsVC = CanvadocsCommentsViewController.new(firstAnnotation, pdfDocument: pdfDocument)
                        commentsVC.comments = [firstAnnotation] + ((self.annotationProvider?.childrenMapping[firstAnnotation.name!] ?? []) as [PSPDFAnnotation])
                        let navigationController = UINavigationController(rootViewController: commentsVC)
                        pdfController.presentViewController(navigationController, options: nil, animated: true, sender: nil, completion: nil)
                    }
                }))

                for menuItem in menuItems {
                    if menuItem.identifier != PSPDFAnnotationMenuCopy && menuItem.identifier != PSPDFAnnotationMenuNote {
                        realMenuItems.append(menuItem)
                    }
                }
                return realMenuItems
            } else if firstAnnotation.type == PSPDFAnnotationType.Ink || firstAnnotation.type == PSPDFAnnotationType.Circle || firstAnnotation.type == PSPDFAnnotationType.Line || firstAnnotation.type == PSPDFAnnotationType.StrikeOut {
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

    public func pdfViewController(pdfController: PSPDFViewController, shouldShowController controller: UIViewController, options: [String : AnyObject]?, animated: Bool) -> Bool {
        if let noteController = controller as? PSPDFNoteAnnotationViewController, annotation = noteController.annotation, pdfDocument = pdfController.document {
            var rootAnnotation: PSPDFAnnotation? = annotation
            var comments: [PSPDFAnnotation] = []
            if let contents = annotation.contents {
                // If this is a brand spanking new note
                if contents == "" && annotation.type == PSPDFAnnotationType.Note {
                    rootAnnotation = nil
                } else if contents != "" { // If this has something and isn't a note type
                    comments = [annotation] + ((self.annotationProvider?.childrenMapping[annotation.name!] ?? []) as [PSPDFAnnotation])
                }
            }
            let commentsVC = CanvadocsCommentsViewController.new(rootAnnotation, pdfDocument: pdfDocument)
            commentsVC.comments = comments
            commentsVC.templateAnnotation = annotation
            let navigationController = UINavigationController(rootViewController: commentsVC)
            pdfController.presentViewController(navigationController, options: nil, animated: true, sender: nil, completion: nil)

            return false
        }

        return true
    }
}

extension CanvadocsPDFDocumentPresenter: PSPDFAnnotationStateManagerDelegate {
    public func annotationStateManager(manager: PSPDFAnnotationStateManager, didChangeState state: String?, to newState: String?, variant: String?, to newVariant: String?) {
        if newState == PSPDFAnnotationStringInk && newVariant == PSPDFAnnotationStringInkVariantPen {
            for (_, drawView) in manager.drawViews {
                drawView.combineInk = false
                drawView.naturalDrawingEnabled = false
            }
        }
    }
}