//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import PSPDFKit
import PSPDFKitUI

class DocViewerPresenter: NSObject {
    var annotationProvider: DocViewerAnnotationProvider?
    let env: AppEnvironment
    let fallbackURL: URL
    var fallbackUsed = false
    let filename: String
    var metadata: APIDocViewerMetadata?
    var previewURL: URL?
    weak var view: DocViewerViewProtocol?

    lazy var session: DocViewerSession = {
        return DocViewerSession { [weak self] in
            DispatchQueue.main.async { self?.sessionIsReady() }
        }
    }()

    init(env: AppEnvironment = .shared, view: DocViewerViewProtocol, filename: String, previewURL: URL?, fallbackURL: URL) {
        self.env = env
        self.view = view
        self.filename = filename
        self.previewURL = previewURL
        self.fallbackURL = fallbackURL
    }

    func viewIsReady() {
        guard
            let url = URL(string: previewURL?.absoluteString ?? "", relativeTo: env.api.baseURL), let loginSession = env.currentSession else {
            return loadFallback()
        }
        session.load(url: url, session: loginSession)
    }

    func sessionIsReady() {
        guard
            session.error == nil,
            let annotations = session.annotations,
            let localURL = session.localURL,
            let metadata = session.metadata,
            let sessionID = session.sessionID
        else { return loadFallback() }

        self.metadata = metadata
        let document = PSPDFDocument(url: localURL)
        if let annotationMeta = metadata.annotations {
            document.defaultAnnotationUsername = annotationMeta.user_name
            document.didCreateDocumentProviderBlock = { documentProvider in
                let provider = DocViewerAnnotationProvider(documentProvider: documentProvider, metadata: annotationMeta, annotations: annotations, api: self.session.api, sessionID: sessionID)
                provider.docViewerDelegate = self
                documentProvider.annotationManager.annotationProviders.insert(provider, at: 0)
                self.annotationProvider = provider
                for (pageKey, rawRotation) in metadata.rotations ?? [:] {
                    if let pageIndex = PageIndex(pageKey), let rotation = Rotation(rawValue: rawRotation) {
                        documentProvider.setRotationOffset(rotation, forPageAt: pageIndex)
                    }
                }
            }
        }
        view?.load(document: document)
    }

    func loadFallback() {
        if let error = session.error { view?.showError(error) }
        if let url = session.localURL {
            view?.load(document: PSPDFDocument(url: url))
            return
        }

        guard !fallbackUsed else { return }
        fallbackUsed = true
        session.error = nil
        session.annotations = []
        session.loadDocument(downloadURL: fallbackURL)
    }
}

private let disabledMenuItems: [String] = [
    PSPDFTextMenu.annotationMenuOpacity.rawValue,
    PSPDFTextMenu.annotationMenuThickness.rawValue,
]

extension DocViewerPresenter: PSPDFViewControllerDelegate {
    // swiftlint:disable function_parameter_count
    public func pdfViewController(
        _ pdfController: PSPDFViewController,
        shouldShow menuItems: [PSPDFMenuItem],
        atSuggestedTargetRect rect: CGRect,
        forSelectedText selectedText: String,
        in textRect: CGRect,
        on pageView: PSPDFPageView
    ) -> [PSPDFMenuItem] {
        return menuItems.filter { $0.identifier != PSPDFTextMenu.annotationMenuHighlight.rawValue }
    }

    public func pdfViewController(
        _ pdfController: PSPDFViewController,
        shouldShow menuItems: [PSPDFMenuItem],
        atSuggestedTargetRect rect: CGRect,
        for annotations: [PSPDFAnnotation]?,
        in annotationRect: CGRect,
        on pageView: PSPDFPageView
    ) -> [PSPDFMenuItem] {
        annotations?.forEach { (pageView.annotationView(for: $0) as? PSPDFFreeTextAnnotationView)?.resizableView?.allowRotating = false }
        if annotations?.count == 1, let annotation = annotations?.first, let document = pdfController.document, let metadata = metadata?.annotations {
            var realMenuItems = [PSPDFMenuItem]()
            realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Comments", bundle: .core, comment: "")) { [weak self] in
                let comments = self?.annotationProvider?.getReplies(to: annotation) ?? []
                let view = CommentListViewController.create(comments: comments, inReplyTo: annotation, document: document, metadata: metadata)
                pdfController.present(UINavigationController(rootViewController: view), options: nil, animated: true, sender: nil, completion: nil)
            })

            realMenuItems.append(contentsOf: menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == PSPDFTextMenu.annotationMenuInspector.rawValue {
                    $0.title = NSLocalizedString("Style", bundle: .core, comment: "")
                }
                return (
                    identifier != PSPDFTextMenu.annotationMenuRemove.rawValue &&
                    identifier != PSPDFTextMenu.annotationMenuCopy.rawValue &&
                    identifier != PSPDFTextMenu.annotationMenuNote.rawValue &&
                    !disabledMenuItems.contains(identifier)
                )
            })

            if annotation.isEditable || metadata.permissions == .readwritemanage {
                realMenuItems.append(PSPDFMenuItem(title: NSLocalizedString("Remove", bundle: .core, comment: ""), image: .icon(.trash, .line), block: {
                    pdfController.document?.remove([annotation], options: nil)
                }, identifier: PSPDFTextMenu.annotationMenuRemove.rawValue))
            }
            return realMenuItems
        }

        return menuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !disabledMenuItems.contains(identifier)
        }
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        return !(controller is PSPDFStampViewController)
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, didTapOn pageView: PSPDFPageView, at viewPoint: CGPoint) -> Bool {
        let state = pdfController.annotationStateManager
        guard state.state == .stamp, let document = pdfController.document, let metadata = metadata?.annotations else { return false }
        let pointAnnotation = DocViewerPointAnnotation()
        pointAnnotation.user = metadata.user_id
        pointAnnotation.userName = metadata.user_name
        pointAnnotation.color = state.drawColor
        pointAnnotation.boundingBox = CGRect(x: 0, y: 0, width: 9.33, height: 13.33)
        pointAnnotation.pageIndex = pageView.pageIndex

        pageView.center(pointAnnotation, aroundPDFPoint: pageView.convert(viewPoint, to: pageView.pdfCoordinateSpace))
        document.add([ pointAnnotation ], options: nil)

        let view = CommentListViewController.create(comments: [], inReplyTo: pointAnnotation, document: document, metadata: metadata)
        pdfController.present(UINavigationController(rootViewController: view), options: nil, animated: true, sender: nil, completion: nil)

        return true
    }
    // swiftlint:enable function_parameter_count
}

extension DocViewerPresenter: DocViewerAnnotationProviderDelegate {
    func annotationDidExceedLimit(annotation: APIDocViewerAnnotation) {
        if annotation.type == .ink { view?.resetInk() }
    }

    func annotationDidFailToSave(error: Error) {
        // TODO: save status bar
    }

    func annotationSaveStateChanges(saving: Bool) {
        // TODO: save status bar
    }
}
