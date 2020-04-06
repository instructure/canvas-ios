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

import UIKit
import PSPDFKit
import PSPDFKitUI

public class DocViewerViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var syncAnnotationsButton: UIButton!

    var annotationProvider: DocViewerAnnotationProvider?
    let env = AppEnvironment.shared
    var fallbackURL: URL!
    var fallbackUsed = false
    var filename = ""
    var metadata: APIDocViewerMetadata?
    weak var parentNavigationItem: UINavigationItem?
    let pdf = PDFViewController()
    var previewURL: URL?
    lazy var session = DocViewerSession { [weak self] in
        performUIUpdate { self?.sessionIsReady() }
    }

    public internal(set) static var hasPSPDFKitLicense = false

    public static func setup(_ secret: Secret) {
        guard let key = secret.string, !hasPSPDFKitLicense else { return }
        SDK.setLicenseKey(key)
        hasPSPDFKitLicense = true
    }

    public static func create(filename: String, previewURL: URL?, fallbackURL: URL, navigationItem: UINavigationItem? = nil) -> DocViewerViewController {
        stylePSPDFKit()

        let controller = loadFromStoryboard()
        controller.parentNavigationItem = navigationItem
        controller.filename = filename
        controller.previewURL = previewURL
        controller.fallbackURL = fallbackURL
        controller.parentNavigationItem = navigationItem
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.color = nil

        embed(pdf, in: contentView)
        pdf.view.isHidden = true
        pdf.updateConfiguration(builder: docViewerConfigurationBuilder)
        pdf.delegate = self

        syncAnnotationsButton.isHidden = true
        syncAnnotationsButton.setTitleColor(.named(.white), for: .normal)
        syncAnnotationsButton.setTitleColor(.named(.textDark), for: .disabled)
        annotationSaveStateChanges(saving: false)

        if let url = URL(string: previewURL?.absoluteString ?? "", relativeTo: env.api.baseURL), let loginSession = env.currentSession {
            session.load(url: url, session: loginSession)
        } else {
            loadFallback()
        }
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
        let document = Document(url: localURL)
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
        load(document: document)
    }

    func loadFallback() {
        if let error = session.error { showError(error) }
        if let url = session.localURL {
            return load(document: Document(url: url))
        }

        guard !fallbackUsed else { return }
        fallbackUsed = true
        session.error = nil
        session.annotations = []
        session.loadDocument(downloadURL: fallbackURL)
    }

    func load(document: Document) {
        pdf.document = document
        pdf.documentViewController?.scrollToSpread(at: 0, scrollPosition: .start, animated: false)
        pdf.view.isHidden = false
        loadingView.isHidden = true

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: pdf.activityButtonItem.target, action: pdf.activityButtonItem.action)
        share.accessibilityIdentifier = "DocViewer.shareButton"
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: pdf.searchButtonItem.target, action: pdf.searchButtonItem.action)
        search.accessibilityIdentifier = "DocViewer.searchButton"
        parentNavigationItem?.rightBarButtonItems = [ share, search ]
    }

    public func showError(_ error: Error) {
        loadingView.isHidden = true
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .default))
        env.router.show(alert, from: self, options: .modal())
    }
}

private let disabledMenuItems: [String] = [
    TextMenu.annotationMenuOpacity.rawValue,
    TextMenu.annotationMenuThickness.rawValue,
]

extension DocViewerViewController: PDFViewControllerDelegate {
    // swiftlint:disable function_parameter_count
    public func pdfViewController(_ pdfController: PDFViewController,
                                  shouldShow menuItems: [MenuItem],
                                  atSuggestedTargetRect rect: CGRect,
                                  forSelectedText selectedText: String,
                                  in textRect: CGRect, on pageView: PDFPageView) -> [MenuItem] {
        return menuItems.filter { $0.identifier != TextMenu.annotationMenuHighlight.rawValue }
    }

    public func pdfViewController(
        _ pdfController: PDFViewController,
        shouldShow menuItems: [MenuItem],
        atSuggestedTargetRect rect: CGRect,
        for annotations: [Annotation]?,
        in annotationRect: CGRect,
        on pageView: PDFPageView
    ) -> [MenuItem] {
        annotations?.forEach { (pageView.annotationView(for: $0) as? FreeTextAnnotationView)?.resizableView?.allowRotating = false }
        if annotations?.count == 1, let annotation = annotations?.first, let document = pdfController.document, let metadata = metadata?.annotations {
            var realMenuItems = [MenuItem]()
            realMenuItems.append(MenuItem(title: NSLocalizedString("Comments", bundle: .core, comment: "")) { [weak self] in
                let comments = self?.annotationProvider?.getReplies(to: annotation) ?? []
                let view = CommentListViewController.create(comments: comments, inReplyTo: annotation, document: document, metadata: metadata)
                pdfController.present(UINavigationController(rootViewController: view), options: nil, animated: true, sender: nil, completion: nil)
            })

            realMenuItems.append(contentsOf: menuItems.filter {
                guard let identifier = $0.identifier else { return true }
                if identifier == TextMenu.annotationMenuInspector.rawValue {
                    $0.title = NSLocalizedString("Style", bundle: .core, comment: "")
                }
                return (
                    identifier != TextMenu.annotationMenuRemove.rawValue &&
                    identifier != TextMenu.annotationMenuCopy.rawValue &&
                    identifier != TextMenu.annotationMenuNote.rawValue &&
                    !disabledMenuItems.contains(identifier)
                )
            })

            if annotation.isEditable || metadata.permissions == .readwritemanage {
                realMenuItems.append(MenuItem(title: NSLocalizedString("Remove", bundle: .core, comment: ""), image: .icon(.trash, .line), block: {
                    pdfController.document?.remove(annotations: [annotation], options: nil)
                }, identifier: TextMenu.annotationMenuRemove.rawValue))
            }
            return realMenuItems
        }

        return menuItems.filter {
            guard let identifier = $0.identifier else { return true }
            return !disabledMenuItems.contains(identifier)
        }
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        return !(controller is StampViewController)
    }

    public func pdfViewController(_ pdfController: PDFViewController, didTapOn pageView: PDFPageView, at viewPoint: CGPoint) -> Bool {
        let state = pdfController.annotationStateManager
        guard state.state == .stamp, let document = pdfController.document, let metadata = metadata?.annotations else { return false }
        let pointAnnotation = DocViewerPointAnnotation()
        pointAnnotation.user = metadata.user_id
        pointAnnotation.userName = metadata.user_name
        pointAnnotation.color = state.drawColor
        pointAnnotation.boundingBox = CGRect(x: 0, y: 0, width: 9.33, height: 13.33)
        pointAnnotation.pageIndex = pageView.pageIndex

        pageView.center(pointAnnotation, aroundPDFPoint: pageView.convert(viewPoint, to: pageView.pdfCoordinateSpace))
        document.add(annotations: [ pointAnnotation ], options: nil)

        let view = CommentListViewController.create(comments: [], inReplyTo: pointAnnotation, document: document, metadata: metadata)
        pdfController.present(UINavigationController(rootViewController: view), options: nil, animated: true, sender: nil, completion: nil)

        return true
    }
    // swiftlint:enable function_parameter_count
}

extension DocViewerViewController: DocViewerAnnotationProviderDelegate {
    func annotationDidExceedLimit(annotation: APIDocViewerAnnotation) {
        guard annotation.type == .ink, pdf.annotationStateManager.state == .ink, let variant = pdf.annotationStateManager.variant else { return }
        pdf.annotationStateManager.toggleState(.ink, variant: variant)
        pdf.annotationStateManager.toggleState(.ink, variant: variant)
    }

    @IBAction func syncAnnotations() {
        annotationProvider?.syncAllAnnotations()
    }

    func annotationDidFailToSave(error: Error) {
        syncAnnotationsButton.isEnabled = true
        syncAnnotationsButton.backgroundColor = .named(.backgroundDanger)
        syncAnnotationsButton.setTitle(NSLocalizedString("Error Saving. Tap to retry.", bundle: .core, comment: ""), for: .normal)
    }

    func annotationSaveStateChanges(saving: Bool) {
        syncAnnotationsButton.isEnabled = false
        syncAnnotationsButton.backgroundColor = .named(.backgroundLight)
        syncAnnotationsButton.setTitle(saving
            ? NSLocalizedString("Saving...", bundle: .core, comment: "")
            : NSLocalizedString("All annotations saved.", bundle: .core, comment: ""),
        for: .normal)
    }
}
