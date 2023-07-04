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

import Combine
import UIKit
import PSPDFKit
import PSPDFKitUI

public class DocViewerViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var syncAnnotationsButton: UIButton!
    let toolbar = UIToolbar()
    let toolbarContainer = FlexibleToolbarContainer()

    var annotationProvider: DocViewerAnnotationProvider?
    let env = AppEnvironment.shared
    public var fallbackURL: URL!
    var fallbackUsed = false
    public var filename = ""
    public var isAnnotatable = false
    var metadata: APIDocViewerMetadata?
    weak var parentNavigationItem: UINavigationItem?
    let pdf = PDFViewController()
    public var previewURL: URL?
    lazy var session = DocViewerSession { [weak self] in
        performUIUpdate { self?.sessionIsReady() }
    }
    private var dragGestureViewModel: AnnotationDragGestureViewModel?
    private var subscriptions = Set<AnyCancellable>()
    private var annotationContextMenuModel: DocViewerAnnotationContextMenuModel?
    private var offlineModeInteractor: OfflineModeInteractor!

    public internal(set) static var hasPSPDFKitLicense = false

    public static func setup(_ secret: Secret) {
        guard let key = secret.string, !hasPSPDFKitLicense else { return }
        SDK.setLicenseKey(key)
        hasPSPDFKitLicense = true
    }

    public static func create(
        filename: String,
        previewURL: URL?,
        fallbackURL: URL,
        navigationItem: UINavigationItem? = nil,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeInteractorLive.shared
    ) -> DocViewerViewController {
        stylePSPDFKit()

        let controller = loadFromStoryboard()
        controller.parentNavigationItem = navigationItem
        controller.filename = filename
        controller.previewURL = previewURL
        controller.fallbackURL = fallbackURL
        controller.parentNavigationItem = navigationItem
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.color = nil
        self.view.backgroundColor = .backgroundMedium

        embed(pdf, in: contentView)
        pdf.delegate = self
        pdf.view.isHidden = true
        pdf.updateConfiguration(builder: docViewerConfigurationBuilder)

        syncAnnotationsButton.setTitleColor(.white, for: .normal)
        syncAnnotationsButton.setTitleColor(.textDark, for: .disabled)
        annotationSaveStateChanges(saving: false)

        let commentPinGestureRecognizer = UITapGestureRecognizer()
        commentPinGestureRecognizer.addTarget(self, action: #selector(commentPinGestureRecognizerDidChangeState))
        commentPinGestureRecognizer.delegate = self
        pdf.interactions.allInteractions.require(toFail: commentPinGestureRecognizer)
        pdf.view.addGestureRecognizer(commentPinGestureRecognizer)

        let dragGestureRecognizer = UIPanGestureRecognizer()
        pdf.view.addGestureRecognizer(dragGestureRecognizer)

        let dragGestureViewModel = AnnotationDragGestureViewModel(pdf: pdf, gestureRecognizer: dragGestureRecognizer)
        self.dragGestureViewModel = dragGestureViewModel

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
            document.didCreateDocumentProviderBlock = { [weak self] documentProvider in
                guard let self = self, let fileAnnotationProvider = documentProvider.annotationManager.fileAnnotationProvider else { return }
                let provider = DocViewerAnnotationProvider(documentProvider: documentProvider,
                                                           fileAnnotationProvider: fileAnnotationProvider,
                                                           metadata: metadata,
                                                           annotations: annotations,
                                                           api: self.session.api,
                                                           sessionID: sessionID,
                                                           isAnnotationEditingDisabled: !self.isAnnotatable || metadata.annotations?.enabled == false)
                provider.docViewerDelegate = self
                documentProvider.annotationManager.annotationProviders = [provider]
                self.annotationProvider = provider
            }
        }
        load(document: document)
    }

    func loadFallback() {
        if let error = session.error {
            // If offline mode is enabled we don't want to show API errors
            if offlineModeInteractor.isOfflineModeEnabled() {
                loadingView.isHidden = true
                return
            } else {
                showError(error)
            }
        }

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
        pdf.view.isHidden = false
        loadingView.isHidden = true

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: pdf.activityButtonItem.target, action: pdf.activityButtonItem.action)
        share.accessibilityIdentifier = "DocViewer.shareButton"
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: pdf.searchButtonItem.target, action: pdf.searchButtonItem.action)
        search.accessibilityIdentifier = "DocViewer.searchButton"
        parentNavigationItem?.rightBarButtonItems = [ share, search ]

        if isAnnotatable, metadata?.annotations?.enabled == true {
            syncAnnotationsButton.isHidden = false
            contentView.addSubview(toolbar)
            toolbar.pin(inside: contentView, bottom: nil)
            contentView.constraints.first { $0.firstAnchor == pdf.view.topAnchor }? .isActive = false
            pdf.view.topAnchor.constraint(equalTo: toolbar.bottomAnchor).isActive = true

            pdf.annotationStateManager.add(self)
            let annotationToolbar = DocViewerAnnotationToolbar(annotationStateManager: pdf.annotationStateManager)
            annotationToolbar.tintColor = Brand.shared.primary
            annotationToolbar.isDragButtonSelected
                .sink { [weak self] isDragEnabled in
                    self?.dragGestureViewModel?.isEnabled = isDragEnabled
                    self?.pdf.interactions.allInteractions.isEnabled = !isDragEnabled
                }
                .store(in: &subscriptions)

            contentView.addSubview(toolbarContainer)
            toolbarContainer.pin(inside: contentView)
            toolbarContainer.flexibleToolbar = annotationToolbar
            toolbarContainer.overlaidBar = toolbar
            toolbarContainer.show(animated: true, completion: nil)

            contentView.layoutIfNeeded()
        }

        annotationContextMenuModel = DocViewerAnnotationContextMenuModel(isAnnotationEnabled: isAnnotatable,
                                                                         metadata: metadata,
                                                                         document: document,
                                                                         annotationProvider: annotationProvider,
                                                                         router: env.router)

        pdf.documentViewController?.scrollToSpread(at: 0, scrollPosition: .start, animated: false)
    }

    public func setContentInsets(_ insets: UIEdgeInsets) {
        pdf.updateConfigurationWithoutReloading { config in
            config.additionalScrollViewFrameInsets = insets
        }
    }

    public func showError(_ error: Error) {
        loadingView.isHidden = true
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .default))
        env.router.show(alert, from: self, options: .modal())
    }
}

extension DocViewerViewController: PDFViewControllerDelegate, AnnotationStateManagerDelegate {

    /** Menu for tapping on an annotation. */
    public func pdfViewController(_ sender: PDFViewController,
                                  menuForAnnotations annotations: [Annotation],
                                  onPageView pageView: PDFPageView,
                                  appearance: EditMenuAppearance,
                                  suggestedMenu: UIMenu)
    -> UIMenu {
        annotationContextMenuModel?.menu(for: annotations,
                                         pageView: pageView,
                                         basedOn: suggestedMenu,
                                         container: sender)
        ?? suggestedMenu
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        return !(controller is StampViewController)
    }
}

extension DocViewerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        pdf.annotationStateManager.state == .stamp &&
            pdf.documentViewController != nil &&
            pdf.document != nil &&
            metadata?.annotations != nil
    }

    @objc func commentPinGestureRecognizerDidChangeState(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended, let documentViewController = pdf.documentViewController else { return }
        let pageViewPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        guard let pageView = documentViewController.visiblePageView(at: pageViewPoint) else { return }
        let viewPoint = gestureRecognizer.location(in: pageView)
        createCommentPinAnnotation(pageView: pageView, at: viewPoint)
    }

    func createCommentPinAnnotation(pageView: PDFPageView, at viewPoint: CGPoint) {
        let state = pdf.annotationStateManager

        guard state.state == .stamp, let document = pdf.document, let metadata = metadata?.annotations else {
            return
        }

        let pointAnnotation = DocViewerPointAnnotation()
        pointAnnotation.user = metadata.user_id
        pointAnnotation.userName = metadata.user_name
        pointAnnotation.color = state.drawColor
        pointAnnotation.boundingBox = CGRect(x: 0, y: 0, width: 9.33, height: 13.33)
        pointAnnotation.pageIndex = pageView.pageIndex

        pageView.center(pointAnnotation, aroundPDFPoint: pageView.convert(viewPoint, to: pageView.pdfCoordinateSpace))
        document.add(annotations: [pointAnnotation], options: nil)

        let view = CommentListViewController.create(comments: [], inReplyTo: pointAnnotation, document: document, metadata: metadata)
        env.router.show(view, from: pdf, options: .modal(embedInNav: true))
    }
}

extension DocViewerViewController: DocViewerAnnotationProviderDelegate {
    func annotationDidExceedLimit(annotation: APIDocViewerAnnotation) {
        guard annotation.type == .ink, pdf.annotationStateManager.state == .ink, let variant = pdf.annotationStateManager.variant else { return }
        pdf.annotationStateManager.toggleState(.ink, variant: variant)
        pdf.annotationStateManager.toggleState(.ink, variant: variant)
    }

    @IBAction func syncAnnotations() {
        annotationProvider?.retryFailedRequest()
    }

    func annotationDidFailToSave(error: Error) { performUIUpdate {
        self.syncAnnotationsButton.isEnabled = true
        self.syncAnnotationsButton.backgroundColor = .backgroundDanger
        self.syncAnnotationsButton.setTitle(NSLocalizedString("Error Saving. Tap to retry.", bundle: .core, comment: ""), for: .normal)
    } }

    func annotationSaveStateChanges(saving: Bool) { performUIUpdate {
        self.syncAnnotationsButton.isEnabled = false
        self.syncAnnotationsButton.backgroundColor = .backgroundLight
        self.syncAnnotationsButton.setTitle(saving
            ? NSLocalizedString("Saving...", bundle: .core, comment: "")
            : NSLocalizedString("All annotations saved.", bundle: .core, comment: ""),
        for: .normal)
    } }
}
