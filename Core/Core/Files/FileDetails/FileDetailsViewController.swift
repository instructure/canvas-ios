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
import PSPDFKit
import PSPDFKitUI
import QuickLook
import QuickLookThumbnailing
import UIKit

public class FileDetailsViewController: UIViewController, CoreWebViewLinkDelegate, ErrorViewController, PageViewEventViewControllerLoggingProtocol {
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

    lazy var editButton = UIBarButtonItem(title: NSLocalizedString("Edit", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(edit))
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

    lazy var files = env.subscribe(GetFile(context: context, fileID: fileID)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context?, fileID: String, originURL: URLComponents? = nil, assignmentID: String? = nil) -> FileDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.context = context
        controller.fileID = fileID
        controller.originURL = originURL
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        contentView.backgroundColor = .backgroundLightest

        arButton.setTitle(NSLocalizedString("Augment Reality", bundle: .core, comment: ""), for: .normal)
        arButton.isHidden = true
        arImageView.isHidden = true

        copiedLabel.text = NSLocalizedString("Copied!", bundle: .core, comment: "")

        lockView.isHidden = true

        if presentingViewController != nil, navigationItem.leftBarButtonItem == nil {
            addDoneButton(side: .left)
        }
        navigationItem.rightBarButtonItem = env.app == .teacher ? editButton : shareButton
        editButton.accessibilityIdentifier = "FileDetails.editButton"
        shareButton.accessibilityIdentifier = "FileDetails.shareButton"
        shareButton.isEnabled = false

        progressView.progress = 0
        progressView.progressTintColor = Brand.shared.primary

        toolbar.isHidden = env.app != .teacher
        toolbar.tintColor = Brand.shared.linkColor
        toolbarLinkButton.accessibilityIdentifier = "FileDetails.copyButton"
        toolbarLinkButton.accessibilityLabel = NSLocalizedString("Copy Link", bundle: .core, comment: "")
        toolbarShareButton.accessibilityIdentifier = "FileDetails.shareButton"

        viewModulesButton.setTitle(NSLocalizedString("View Modules", bundle: .core, comment: ""), for: .normal)
        viewModulesButton.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(fileEdited(_:)), name: .init("file-edit"), object: nil)

        view.layoutIfNeeded()
        files.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
        env.userDefaults?.submitAssignmentCourseID = context?.contextType == .course ? context?.id : nil
        env.userDefaults?.submitAssignmentID = assignmentID
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveAnnotations()
        downloadTask?.cancel()
        stopTrackingTimeOnViewController(eventName: "\(context?.pathComponent ?? "")/files/\(fileID)")
    }

    @objc func fileEdited(_ notification: NSNotification) {
        guard notification.userInfo?["id"] as? String == fileID else { return }
        files.refresh(force: true)
    }

    func update() {
        guard let file = files.first else {
            if let error = files.error {
                // If file download failed because of unauthorization error and we have a verifier token, then we modify the url and try to open the file in a webview.
                if var url = originURL, url.containsVerifier, case .unauthorized = (error as? APIError) {
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
            } else if files.requested, !files.pending {
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
        let webView = CoreWebView(invertColorsInDarkMode: true)
        contentView.addSubview(webView)
        webView.pin(inside: contentView)
        webView.linkDelegate = self
        webView.accessibilityLabel = "FileDetails.webView"
        progressView.progress = 0
        loadObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            self?.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            guard webView.estimatedProgress >= 1 else { return }
            self?.loadObservation = nil
            self?.doneLoading()
        }

        if isLocalURL {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            webView.load(URLRequest(url: url))
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
            options: .modal(.formSheet, isDismissable: false, embedInNav: true)
        )
    }

    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let url = localURL else { return }
        let pdf = children.first { $0 is PDFViewController } as? PDFViewController
        try? pdf?.document?.save()
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
        guard let sessionID = env.currentSession?.uniqueID, let name = files.first?.filename else { return nil }
        return "\(sessionID)/\(fileID)/\(name)"
    }
}

extension FileDetailsViewController: URLSessionDownloadDelegate {
    /// This must be called to set `localURL` before initiating download, otherwise there
    /// will be a threading issue with trying to access core data from a different thread.
    func prepLocalURL() -> URL? {
        guard let filePathComponent = filePathComponent else { return nil }

        if files.first?.mimeClass == "pdf" {
            //  check docs directory first if they have already added/modified annotations on an existing pdf
            let docsURL = URL.documentsDirectory.appendingPathComponent(filePathComponent)
            if FileManager.default.fileExists(atPath: docsURL.path) { return docsURL }
        }

        return URL.temporaryDirectory.appendingPathComponent(filePathComponent)
    }

    func downloadFile(at url: URL) {
        localURL = prepLocalURL()
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
            return showError(APIError.from(
                data: try? Data(contentsOf: location),
                response: downloadTask.response,
                error: NSError.internalError()
            ))
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

    func downloadComplete() {
        guard let file = files.first, let localURL = localURL, FileManager.default.fileExists(atPath: localURL.path) else { return }
        shareButton.isEnabled = true
        switch (file.mimeClass, file.contentType) {
        case ("audio", _):
            embedAudioView(for: localURL)
        case (_, let type) where type?.hasPrefix("audio/") == true:
            embedAudioView(for: localURL)
        case ("image", _), (_, "image/heic"):
            embedImageView(for: localURL)
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
    func embedImageView(for url: URL) {
        let image = UIImageView(image: UIImage(contentsOfFile: url.path))
        image.accessibilityIdentifier = "FileDetails.imageView"
        image.accessibilityLabel = files.first?.displayName ?? NSLocalizedString("File", bundle: .core, comment: "")
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

extension FileDetailsViewController: PDFViewControllerDelegate {
    func embedPDFView(for url: URL) {
        guard DocViewerViewController.hasPSPDFKitLicense else {
            return embedWebView(for: url)
        }
        stylePSPDFKit()

        let document = Document(url: url)
        document.annotationSaveMode = .embedded
        let controller = PDFViewController(document: document, configuration: PDFConfiguration { (builder) -> Void in
            docViewerConfigurationBuilder(builder)
            builder.editableAnnotationTypes = [ .link, .highlight, .underline, .strikeOut, .squiggly, .freeText, .ink, .square, .circle, .line, .polygon, .eraser ]
            builder.propertiesForAnnotations[.square] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.circle] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.line] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.polygon] = [["color"], ["lineWidth"]]
            builder.sharingConfigurations = [ DocumentSharingConfiguration { builder in
                builder.annotationOptions = .flatten
                builder.pageSelectionOptions = .all
            }, ]

            // Override the override
            builder.overrideClass(AnnotationToolbar.self, with: AnnotationToolbar.self)
        })
        controller.annotationToolbarController?.toolbar.toolbarPosition = .left
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navigationController?.navigationBar.barTintColor
        controller.annotationToolbarController?.toolbar.standardAppearance = appearance
        controller.delegate = self
        embed(controller, in: contentView)
        addPDFAnnotationChangeNotifications()

        let annotate = controller.annotationButtonItem
        annotate.image = .highlighterLine
        annotate.accessibilityIdentifier = "FileDetails.annotateButton"
        let search = controller.searchButtonItem
        search.accessibilityIdentifier = "FileDetails.searchButton"
        navigationItem.rightBarButtonItems = [
            env.app == .teacher ? editButton : shareButton,
            annotate,
            search,
        ]
        NotificationCenter.default.post(name: .init("FileViewControllerBarButtonItemsDidChange"), object: nil)

        doneLoading()
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
            let to = URL.documentsDirectory.appendingPathComponent(filePathComponent)
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

    public func pdfViewController(
        _ pdfController: PDFViewController,
        shouldShow menuItems: [MenuItem],
        atSuggestedTargetRect rect: CGRect,
        for annotations: [Annotation]?,
        in annotationRect: CGRect,
        on pageView: PDFPageView
    ) -> [MenuItem] {
        return menuItems.compactMap { item in
            guard item.identifier != TextMenu.annotationMenuNote.rawValue else { return nil }
            if item.identifier == TextMenu.annotationMenuInspector.rawValue {
                item.title = NSLocalizedString("Style", bundle: .core, comment: "")
            }
            if item.identifier == TextMenu.annotationMenuRemove.rawValue {
                return MenuItem(title: item.title, image: .trashLine, block: item.actionBlock, identifier: item.identifier)
            }
            return item
        }
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
