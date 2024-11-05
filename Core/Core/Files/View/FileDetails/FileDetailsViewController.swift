//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import AVKit
import Combine
import PSPDFKit
import PSPDFKitUI
import QuickLook
import QuickLookThumbnailing
import UIKit

public class FileDetailsViewController: ScreenViewTrackableViewController, CoreWebViewLinkDelegate, ErrorViewController {
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var arImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copiedView: UIView!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarLinkButton: UIBarButtonItem!
    @IBOutlet weak var toolbarShareButton: UIBarButtonItem!
    @IBOutlet weak var viewModulesButton: UIButton!

    lazy var editButton = UIBarButtonItem(title: String(localized: "Edit", bundle: .core), style: .plain, target: self, action: #selector(edit))
    lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))

    var assignmentID: String?
    var context: Context?
    var downloadTask: APITask?
    let env = AppEnvironment.shared
    public var fileID: String = ""
    var loadObservation: NSKeyValueObservation?
    var remoteURL: URL?
    var localURL: URL?
    var pdfAnnotationsMutatedMoveToDocsDirectory = false
    var originURL: URLComponents?
    var canEdit: Bool = true
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context?.pathComponent ?? "")/files/\(fileID)"
    )
    lazy var files = env.subscribe(GetFile(context: context, fileID: fileID)) { [weak self] in
        self?.update()
    }
    public var offlineFileSource: OfflineFileSource?
    private var accessReportInteractor: FileAccessReportInteractor?
    private var subscriptions = Set<AnyCancellable>()
    private var offlineFileInteractor: OfflineFileInteractor?
    private var imageLoader: ImageLoader?
    private var isFileLocalURLAvailable: Bool { localURL != nil }
    private var isPresentingOfflineModeAlert = false

    public static func create(
        context: Context?,
        fileID: String,
        originURL: URLComponents? = nil,
        assignmentID: String? = nil,
        canEdit: Bool = true,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()
    ) -> FileDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.context = context
        controller.fileID = fileID
        controller.originURL = originURL
        controller.offlineFileInteractor = offlineFileInteractor
        controller.canEdit = canEdit && controller.env.app == .teacher

        if let context {
            controller.accessReportInteractor = FileAccessReportInteractor(context: context,
                                                                           fileID: fileID,
                                                                           api: controller.env.api)
        }

        return controller
    }

    public static func create(
        context: Context?,
        fileID: String,
        offlineFileSource: OfflineFileSource,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()
    ) -> FileDetailsViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.fileID = fileID
        controller.offlineFileSource = offlineFileSource
        controller.offlineFileInteractor = offlineFileInteractor

        if let context {
            controller.accessReportInteractor = FileAccessReportInteractor(context: context,
                                                                           fileID: fileID,
                                                                           api: controller.env.api)
        }

        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        contentView.backgroundColor = .backgroundLightest

        arButton.setTitle(String(localized: "Augment Reality", bundle: .core), for: .normal)
        arButton.isHidden = true
        arImageView.isHidden = true

        copiedLabel.text = String(localized: "Copied!", bundle: .core)

        lockView.isHidden = true

        if presentingViewController != nil, navigationItem.leftBarButtonItem == nil {
            addDoneButton(side: .left)
        }
        navigationItem.rightBarButtonItem = canEdit ? editButton : shareButton
        editButton.accessibilityIdentifier = "FileDetails.editButton"
        shareButton.accessibilityIdentifier = "FileDetails.shareButton"
        shareButton.isEnabled = false

        progressView.progress = 0
        progressView.progressTintColor = Brand.shared.primary

        toolbar.isHidden = env.app != .teacher
        toolbar.tintColor = Brand.shared.linkColor
        toolbarLinkButton.accessibilityIdentifier = "FileDetails.copyButton"
        toolbarLinkButton.accessibilityLabel = String(localized: "Copy Link", bundle: .core)
        toolbarShareButton.accessibilityIdentifier = "FileDetails.shareButton"

        viewModulesButton.setTitle(String(localized: "View Modules", bundle: .core), for: .normal)
        viewModulesButton.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(fileEdited(_:)), name: .init("file-edit"), object: nil)

        view.layoutIfNeeded()
        files.refresh()

        accessReportInteractor?
            .reportFileAccess()
            .sink()
            .store(in: &subscriptions)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        env.userDefaults?.submitAssignmentCourseID = context?.contextType == .course ? context?.id : nil
        env.userDefaults?.submitAssignmentID = assignmentID
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveAnnotations()
        downloadTask?.cancel()
    }

    @objc func fileEdited(_ notification: NSNotification) {
        guard notification.userInfo?["id"] as? String == fileID else { return }
        files.refresh(force: true)
    }

    func update() {
        if offlineFileInteractor?.isOffline == true {
            return handleOfflineFileLoad()
        }

        guard let file = files.first else {
            if let error = files.error {
                // If file download failed because of a forbidden error and we have a verifier token, then we modify the url and try to open the file in a webview.
                if var url = originURL, url.containsVerifier, error.isForbidden {
                    if !url.path.hasSuffix("download") {
                        url.path.append("/download")
                        url.queryItems?.append(URLQueryItem(name: "download_frd", value: "1"))
                    }
                    if let urlRaw = url.url {
                        embedWebView(for: urlRaw, isLocalURL: false)
                    } else {
                        showError(error)
                    }
                } else {
                    showError(error)
                }
            } else if files.requested, !files.pending, localURL == nil {
                // File was deleted, go back.
                env.router.dismiss(self)
            }
            return
        }

        title = file.displayName
        lockLabel.text = file.lockExplanation
        lockView.isHidden = !file.lockedForUser
        // TODO: viewModulesButton.isHidden = file.lockInfo.contextModule != nil
        if file.lockedForUser {
            doneLoading()
        } else if let file = files.first, let url = file.url, remoteURL != url {
            remoteURL = url
            downloadFile(at: url)
        }
    }

    private func handleOfflineFileLoad() {
        if isFileLocalURLAvailable {
            /// File is already loaded, nothing to do, this is just un unnecessary update() call.
            return
        }

        if isPresentingOfflineModeAlert {
            /// We failed to load the offline file and the error dialog is alread presented.
            /// Nothing to do, this is just an unnecessary update() call.
            return
        }

        if offlineFileInteractor?.isItemAvailableOffline(source: offlineFileSource) == true {
            // File is not in CoreData but downloaded via rich content parsing
           downloadFile(at: nil)
        } else if let file = files.first, let url = file.url {
            // File is in CoreData and was downloaded as a course file in the Files course tab.
            downloadFile(at: url)
        } else {
            isPresentingOfflineModeAlert = true
            // This is a file that was not downloaded for offline mode.
            UIAlertController.showItemNotAvailableInOfflineAlert { [weak self] in
                guard let self else { return }
                env.router.dismiss(self)
            }
        }
    }

    func embedAudioView(for url: URL) {
        let player = AudioPlayerViewController.create()
        player.load(url: url)
        let container = UIView()
        contentView.addSubview(container)
        container.pin(inside: contentView, leading: 16, trailing: 16, top: nil, bottom: nil)
        container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        embed(player, in: container)
        doneLoading()
    }

    func embedVideoView(for url: URL) {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.view.accessibilityIdentifier = "FileDetails.videoPlayer"
        embed(controller, in: contentView)
        BackgroundVideoPlayer.shared.connect(controller)
        doneLoading()
    }

    func embedWebView(for url: URL, isLocalURL: Bool = true) {
        let webView = CoreWebView(features: [.invertColorsInDarkMode])
        contentView.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: contentView)
        webView.linkDelegate = self
        webView.accessibilityLabel = "FileDetails.webView"
        progressView.progress = 0
        setupLoadObservation(for: webView)

        if isLocalURL {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            webView.load(URLRequest(url: url))
        }
    }

    func embedImageWrappedInWebView(for url: URL) {
        let webView = ImageWrapperUIKitWebView()
        contentView.addSubview(webView)
        webView.pin(inside: contentView)
        webView.accessibilityLabel = "FileDetails.webView"
        progressView.progress = 0
        setupLoadObservation(for: webView)

        webView.loadImageURL(url, baseURL: URL.Directories.temporary, fill: false, restrictZoom: false)
    }

    private func setupLoadObservation(for webView: WKWebView) {
        loadObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            self?.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            guard webView.estimatedProgress >= 1 else { return }
            self?.loadObservation = nil
            self?.doneLoading()
        }
    }

    func doneLoading() {
        spinnerView.isHidden = true
        progressView.isHidden = true
        let courseID = context?.contextType == .course ? context?.id : nil
        NotificationCenter.default.post(moduleItem: .file(fileID), completedRequirement: .view, courseID: courseID ?? "")
    }

    @IBAction func viewModules() {
        env.router.route(to: "\(context?.pathComponent ?? "")/modules", from: self)
    }

    @objc func edit() {
        env.router.route(
            to: "\(context?.pathComponent ?? "")/files/\(fileID)/edit",
            from: self,
            options: .modal(isDismissable: false, embedInNav: true)
        )
    }

    @IBAction func share(_ sender: UIBarButtonItem) {
        guard offlineFileInteractor?.isOffline == false else { return UIAlertController.showItemNotAvailableInOfflineAlert() }
        guard let url = localURL else { return }
        let pdf = children.first { $0 is PDFViewController } as? PDFViewController
        try? pdf?.document?.save()
        let controller = CoreActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = sender
        env.router.show(controller, from: self, options: .modal())
    }

    @IBAction func copyLink() {
        UIPasteboard.general.url = env.api.baseURL.appendingPathComponent("files/\(fileID)/download")
        UIAccessibility.post(notification: .announcement, argument: copiedLabel.text)
        copiedView.alpha = 0
        copiedView.isHidden = false
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.copiedView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 1, animations: {
                self.copiedView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.copiedView.isHidden = true
            })
        })
    }

    var filePathComponent: String? {
        guard
            let sessionID = env.currentSession?.uniqueID
        else {
            return nil
        }
        switch offlineFileSource {
        case .privateFile:
            return offlineFileInteractor?.filePath(
                source: offlineFileSource
            )
        default:
            guard let name = files.first?.filename else { return nil }
            if offlineFileInteractor?.isOffline == true {
                guard let contextId = context?.id, let fileName = files.first?.filename else { return nil }
                return offlineFileInteractor?.filePath(sessionID: sessionID, courseId: contextId, fileID: fileID, fileName: fileName)
            } else {
                return "\(sessionID)/\(fileID)/\(name)"
            }
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension FileDetailsViewController: URLSessionDownloadDelegate, LocalFileURLCreator {
    func downloadFile(at url: URL?) {
        switch offlineFileSource {
        case .privateFile:
            loadOfflineFile()
        default:
            guard let url else { return }
            loadCoreDataFile(url: url)
        }
    }

    private func loadOfflineFile() {
        guard let filePathComponent = filePathComponent else { return }
        let fileURL = URL.Directories.documents.appendingPathComponent(filePathComponent)
        var mimeClass = fileURL.mimeType()
        // application/pdf --> pdf
        // image/png, image/jpeg, ... --> image
        if mimeClass.contains("application") {
            if let suffix = mimeClass.split(separator: "/").last {
                mimeClass = String(suffix)
            }
        } else {
            if let prefix = mimeClass.split(separator: "/").first {
                mimeClass = String(prefix)
            }
        }

        localURL = prepareLocalURL(
            fileName: filePathComponent,
            mimeClass: mimeClass,
            location: URL.Directories.documents
        )
        title = localURL?.lastPathComponent

        if let path = localURL?.path, FileManager.default.fileExists(atPath: path) { return downloadComplete(mimeClass: mimeClass, contentType: nil) }
    }

    private func loadCoreDataFile(url: URL) {
        guard
            let filePathComponent = filePathComponent,
            let mimeClass = files.first?.mimeClass
        else {
            return
        }

        let location = offlineFileInteractor?.isOffline == true ? URL.Directories.documents : URL.Directories.temporary

        localURL = prepareLocalURL(
            fileName: filePathComponent,
            mimeClass: mimeClass,
            location: location
        )

        if let path = localURL?.path, FileManager.default.fileExists(atPath: path) { return downloadComplete() }
        downloadTask = API(urlSession: URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)).makeDownloadRequest(url)
        downloadTask?.resume()
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        performUIUpdate {
            self.progressView.setProgress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite), animated: true)
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let localURL = localURL else { return }
        if let status = (downloadTask.response as? HTTPURLResponse)?.statusCode, status >= 400 {
            if status == 404 {
                return performUIUpdate {
                    self.showFileNoLongerExistsDialog()
                }
            } else {
                return showError(APIError.from(
                    data: try? Data(contentsOf: location),
                    response: downloadTask.response,
                    error: NSError.internalError()
                ))
            }
        }
        do {
            try FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: location, to: localURL)
        } catch {
            showError(error)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, (error as NSError).code != NSURLErrorCancelled { showError(error) }
        downloadTask = nil
        performUIUpdate { self.downloadComplete() }
        session.finishTasksAndInvalidate()
    }

    private func showFileNoLongerExistsDialog() {
        let alert = UIAlertController(title: String(localized: "File No Longer Exists", bundle: .core),
                                      message: String(localized: "The file has been deleted by the author.", bundle: .core),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Close", bundle: .core),
                                      style: .default,
                                      handler: { [env] _ in
            env.router.dismiss(self)
        }))
        env.router.show(alert, from: self, options: .modal())
    }

    func downloadComplete() {
        guard let file = files.first else { return }
        return downloadComplete(mimeClass: file.mimeClass, contentType: file.contentType)
    }

    func downloadComplete(mimeClass: String?, contentType: String?) {
        guard let localURL = localURL, FileManager.default.fileExists(atPath: localURL.path) else { return }
        if localURL.lastPathComponent == "download" && localURL.pathExtension == "" {
            return performUIUpdate {
                self.showFileNoLongerExistsDialog()
            }
        }
        shareButton.isEnabled = true
        switch (mimeClass, contentType) {
        case ("audio", _):
            embedAudioView(for: localURL)
        case (_, let type) where type?.hasPrefix("audio/") == true:
            embedAudioView(for: localURL)
        case ("image", _), (_, "image/heic"):
            embedImageOrWebView(for: localURL)
        case (_, "model/vnd.usdz+zip"):
            embedQLThumbnail()
        case ("pdf", _):
            embedPDFView(for: localURL)
        case ("video", _):
            embedVideoView(for: localURL)
        default:
            embedWebView(for: localURL)
        }
    }
}

extension FileDetailsViewController: UIScrollViewDelegate {
    private func embedImageOrWebView(for url: URL) {
        imageLoader = ImageLoader(url: url, frame: .zero, shouldFailForAnimatedGif: true) { [weak self] result in
            if result.error as? ImageLoaderError == .animatedGifFound {
                self?.embedImageWrappedInWebView(for: url)
                self?.imageLoader = nil
            } else {
                self?.embedImageView(for: url)
                self?.imageLoader = nil
            }
        }
        imageLoader?.load()
    }

    private func embedImageView(for url: URL) {
        let image = UIImageView(image: UIImage(contentsOfFile: url.path))
        image.accessibilityIdentifier = "FileDetails.imageView"
        image.accessibilityLabel = files.first?.displayName ?? String(localized: "File", bundle: .core)
        image.isAccessibilityElement = true
        let imageSize = image.frame.size
        let scroll = UIScrollView(frame: contentView.bounds)
        contentView.addSubview(scroll)
        scroll.addSubview(image)
        scroll.pin(inside: contentView)
        scroll.contentSize = imageSize
        scroll.delegate = self
        scroll.maximumZoomScale = UIScreen.main.scale
        scroll.minimumZoomScale = min(1, scroll.bounds.width / imageSize.width)
        scroll.zoomScale = scroll.minimumZoomScale
        scrollViewDidZoom(scroll)
        image.load(url: localURL) // handle gif animation
        doneLoading()
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let image = scrollView.subviews[0]
        let x = max(0, (scrollView.bounds.width - image.frame.width) / 2)
        let y = max(0, (scrollView.bounds.height - image.frame.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidZoom(scrollView)
    }
}

extension FileDetailsViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func embedQLThumbnail() {
        if let localURL = localURL {
            let request = QLThumbnailGenerator.Request(fileAt: localURL, size: arImageView.bounds.size, scale: UIScreen.main.scale, representationTypes: .thumbnail)
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { [weak self] thumb, _ in performUIUpdate {
                self?.doneLoading()
                self?.arButton.isHidden = false
                if let image = thumb?.uiImage {
                    self?.arImageView.image = image
                    self?.arImageView.isHidden = false
                }
            } }
        } else {
            doneLoading()
            arButton.isHidden = false
        }
    }

    @IBAction func openQLPreview() {
        let controller = QLPreviewController()
        controller.dataSource = self
        env.router.show(controller, from: self, options: .modal())
    }

    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return localURL != nil ? 1 : 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return localURL! as NSURL
    }
}

extension FileDetailsViewController: PDFViewControllerDelegate, FlexibleToolbarContainerDelegate {
    func embedPDFView(for url: URL) {
        guard DocViewerViewController.hasPSPDFKitLicense else {
            return embedWebView(for: url)
        }
        stylePSPDFKit()

        let document = Document(url: url)
        document.annotationSaveMode = .embedded
        let controller = PDFViewController(document: document, configuration: PDFConfiguration { builder in
            docViewerConfigurationBuilder(builder)
            builder.editableAnnotationTypes = [ .link, .highlight, .underline, .strikeOut, .squiggly, .freeText, .ink, .square, .circle, .line, .polygon, .eraser ]
            builder.propertiesForAnnotations[.square] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.circle] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.line] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.polygon] = [["color"], ["lineWidth"]]
            builder.sharingConfigurations = [ DocumentSharingConfiguration { builder in
                builder.annotationOptions = .flatten
                builder.pageSelectionOptions = .all
            } ]

            // Override the override
            builder.overrideClass(AnnotationToolbar.self, with: AnnotationToolbar.self)
        })
        controller.annotationToolbarController?.annotationToolbar.toolbarPosition = defaultToolbarPosition()
        controller.annotationToolbarController?.delegate = self

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navigationController?.navigationBar.barTintColor
        controller.annotationToolbarController?.toolbar.standardAppearance = appearance

        let annotationToolbarProxy = AnnotationToolbar.appearance()
        annotationToolbarProxy.tintColor = navigationController?.navigationBar.tintColor

        controller.delegate = self
        embed(controller, in: contentView)
        addPDFAnnotationChangeNotifications()

        let annotate = controller.annotationButtonItem
        annotate.image = .highlighterLine
        annotate.accessibilityIdentifier = "FileDetails.annotateButton"
        let search = controller.searchButtonItem
        search.accessibilityIdentifier = "FileDetails.searchButton"
        navigationItem.rightBarButtonItems = [
            canEdit ? editButton : shareButton,
            annotate,
            search
        ]
        NotificationCenter.default.post(name: .init("FileViewControllerBarButtonItemsDidChange"), object: nil)

        doneLoading()
    }

    private func defaultToolbarPosition() -> FlexibleToolbar.Position {
        let isRegular = view.traitCollection.horizontalSizeClass == .regular
        let isRightToLeft = view.traitCollection.layoutDirection == .rightToLeft
        return !isRegular || isRightToLeft ? .left : .right
    }

    public func flexibleToolbarContainerContentRect(_ container: FlexibleToolbarContainer, for position: FlexibleToolbar.Position) -> CGRect {

        let isCompact = container.traitCollection.horizontalSizeClass == .compact
        let padding: CGFloat = isCompact ? 10 : 16

        let safeInsets = container.safeAreaInsets
        let contentFrame = contentView.convert(contentView.bounds, to: container)
        let toolbarRect = CGRect(
            x: safeInsets.left + padding,
            y: contentFrame.origin.y,
            width: container.bounds.width - safeInsets.left - safeInsets.right - 2 * padding,
            height: contentFrame.height
        )

        return toolbarRect
    }

    func saveAnnotations() {
        for child in children {
            if let pdf = child as? PDFViewController {
                _ = try? pdf.document?.save()
                if let document = pdf.document {
                    pdfViewController(pdf, didSave: document, error: nil)
                }
            }
        }
    }

    public func pdfViewController(_ pdfController: PDFViewController, didSave document: Document, error: Error?) {
        if pdfAnnotationsMutatedMoveToDocsDirectory, let filePathComponent = filePathComponent {
            let to = URL.Directories.documents.appendingPathComponent(filePathComponent)
            if !FileManager.default.fileExists(atPath: to.path), let from = document.fileURL {
                do {
                    try FileManager.default.createDirectory(at: to.deletingLastPathComponent(), withIntermediateDirectories: true)
                    if FileManager.default.fileExists(atPath: to.path) {
                        try FileManager.default.removeItem(at: to)
                    }
                    try FileManager.default.moveItem(at: from, to: to)
                } catch {
                    print("error moving file: \(error)")
                }
            }
        }
    }

    /** Menu for tapping on an annotation. */
    public func pdfViewController(_ sender: PDFViewController,
                                  menuForAnnotations annotations: [Annotation],
                                  onPageView pageView: PDFPageView,
                                  appearance: EditMenuAppearance,
                                  suggestedMenu: UIMenu)
    -> UIMenu {
        guard let annotation = annotations.first else {
            return suggestedMenu.replacingChildren([])
        }

        let menuActions = suggestedMenu.allActions.compactMap {
            // Rename Inspector menu to Style
            if $0.identifier == .PSPDFKit.inspector {
                return UIAction.style(annotation: annotation, pageView: pageView)
            }
            // Replace default red Trash icon menu with custom one
            if $0.identifier == .PSPDFKit.delete, let document = sender.document {
                return UIAction.deleteAnnotation(document: document, annotation: annotation)
            }
            // Remove Note menu
            if $0.identifier == .PSPDFKit.comments {
                return nil
            }

            return $0
        }

        return suggestedMenu.replacingChildren(menuActions)
    }

    public func pdfViewController(_ pdfController: PDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        if controller is StampViewController { return false }
        if controller is UIActivityViewController {
            _ = try? pdfController.document?.save()
        }
        return true
    }

    func addPDFAnnotationChangeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(annotationChangedNotification(notification:)), name: .PSPDFAnnotationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(annotationChangedNotification(notification:)), name: .PSPDFAnnotationsRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(annotationChangedNotification(notification:)), name: .PSPDFAnnotationsAdded, object: nil)
    }

    @objc
    func annotationChangedNotification(notification: Notification) {
        pdfAnnotationsMutatedMoveToDocsDirectory = true
    }
}
