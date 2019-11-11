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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var arImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var viewModulesButton: UIButton!

    var assignmentID: String?
    var context: Context = ContextModel.currentUser
    var downloadTask: URLSessionTask?
    let env = AppEnvironment.shared
    var fileID: String = ""
    var loadObservation: NSKeyValueObservation?
    var remoteURL: URL?

    lazy var files = env.subscribe(GetFile(context: context, fileID: fileID)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context, fileID: String, assignmentID: String? = nil) -> FileDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.context = context
        controller.fileID = fileID
        return controller
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        navigationController?.navigationBar.barStyle == .black ? .lightContent : .default
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        contentView.backgroundColor = .named(.backgroundLightest)

        activityView.color = Brand.shared.primary

        arButton.setTitle(NSLocalizedString("Augment Reality", bundle: .core, comment: ""), for: .normal)
        arButton.isHidden = true
        arImageView.isHidden = true

        lockView.isHidden = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FileDetails.shareButton"
        navigationItem.rightBarButtonItem?.isEnabled = false

        progressView.progress = 0
        progressView.progressTintColor = Brand.shared.primary

        viewModulesButton.setTitle(NSLocalizedString("View Modules", bundle: .core, comment: ""), for: .normal)
        viewModulesButton.isHidden = true

        files.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
        env.userDefaults?.submitAssignmentCourseID = context.contextType == .course ? context.id : nil
        env.userDefaults?.submitAssignmentID = assignmentID
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTask?.cancel()
        stopTrackingTimeOnViewController(eventName: "/\(context.pathComponent)/files/\(fileID)")
    }

    func update() {
        guard let file = files.first else {
            if let error = files.error { showError(error) }
            return
        }

        title = file.displayName
        lockLabel.text = file.lockExplanation
        lockView.isHidden = !file.lockedForUser
        // TODO: viewModulesButton.isHidden = file.lockInfo.contextModule != nil
        if let file = files.first, let url = file.url, remoteURL != url {
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
        doneLoading()
    }

    func embedWebView(for url: URL) {
        let webView = CoreWebView()
        contentView.addSubview(webView)
        webView.pin(inside: contentView)
        webView.linkDelegate = self
        progressView.progress = 0
        loadObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            self?.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            guard webView.estimatedProgress >= 1 else { return }
            self?.loadObservation = nil
            self?.doneLoading()
        }
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func doneLoading() {
        activityView.stopAnimating()
        progressView.isHidden = true
        NotificationCenter.default.post(name: .init("CBIModuleItemProgressUpdatedNotification"), object: nil, userInfo: [
            "CBIUpdatedModuleItemIDStringKey": fileID,
            "CBIUpdatedModuleItemTypeKey": "must_view",
        ])
    }

    @IBAction func viewModules() {
        env.router.route(to: Route.modules(forCourse: context.id), from: self, options: nil)
    }

    @objc func share(_ sender: UIBarButtonItem) {
        guard let url = localURL else { return }
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = sender
        env.router.show(controller, from: self, options: .modal)
    }
}

extension FileDetailsViewController: URLSessionDownloadDelegate {
    var localURL: URL? {
        guard let sessionID = env.currentSession?.uniqueID, let name = files.first?.filename else { return nil }
        let base = files.first?.mimeClass == "pdf" ? URL.documentsDirectory : URL.temporaryDirectory
        return base.appendingPathComponent("\(sessionID)/\(fileID)/\(name)")
    }

    func downloadFile(at url: URL) {
        if let path = localURL?.path, FileManager.default.fileExists(atPath: path) { return downloadComplete() }
        downloadTask = URLSessionAPI.delegateURLSession(.ephemeral, self, nil).downloadTask(with: url)
        downloadTask?.resume()
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        performUIUpdate {
            self.progressView.setProgress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite), animated: true)
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let localURL = localURL else { return }
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
        navigationItem.rightBarButtonItem?.isEnabled = true
        switch (file.mimeClass, file.contentType) {
        case ("audio", _):
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
}

extension FileDetailsViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func embedQLThumbnail() {
        if #available(iOS 13, *), let localURL = localURL {
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
        env.router.show(controller, from: self, options: .modal)
    }

    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return localURL != nil ? 1 : 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return localURL! as NSURL
    }
}

extension FileDetailsViewController: PSPDFViewControllerDelegate {
    func embedPDFView(for url: URL) {
        stylePSPDFKit()

        let document = PSPDFDocument(url: url)
        document.annotationSaveMode = .embedded
        let controller = PSPDFViewController(document: document, configuration: PSPDFConfiguration { (builder) -> Void in
            docViewerConfigurationBuilder(builder)
            builder.editableAnnotationTypes = [ .link, .highlight, .underline, .strikeOut, .squiggly, .freeText, .ink, .square, .circle, .line, .polygon, .eraser ]
            builder.propertiesForAnnotations[.square] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.circle] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.line] = [["color"], ["lineWidth"]]
            builder.propertiesForAnnotations[.polygon] = [["color"], ["lineWidth"]]
            builder.sharingConfigurations = [ PSPDFDocumentSharingConfiguration { builder in
                builder.annotationOptions = .flatten
                builder.pageSelectionOptions = .all
            }, ]

            // Override the override
            builder.overrideClass(PSPDFAnnotationToolbar.self, with: PSPDFAnnotationToolbar.self)
        })
        controller.annotationToolbarController?.toolbar.toolbarPosition = .positionLeft
        if #available(iOS 13, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationController?.navigationBar.barTintColor
            controller.annotationToolbarController?.toolbar.standardAppearance = appearance
        }
        controller.delegate = self
        embed(controller, in: contentView)

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: controller.activityButtonItem.target, action: controller.activityButtonItem.action)
        share.accessibilityIdentifier = "FileDetails.shareButton"
        let annotate = controller.annotationButtonItem
        annotate.image = .icon(.highlighter, .line)
        annotate.accessibilityIdentifier = "FileDetails.annotateButton"
        let search = controller.searchButtonItem
        search.accessibilityIdentifier = "FileDetails.searchButton"
        navigationItem.rightBarButtonItems = [ share, annotate, search ]
        NotificationCenter.default.post(name: .init("FileViewControllerBarButtonItemsDidChange"), object: nil)

        doneLoading()
    }

    public func pdfViewController(
        _ pdfController: PSPDFViewController,
        shouldShow menuItems: [PSPDFMenuItem],
        atSuggestedTargetRect rect: CGRect,
        for annotations: [PSPDFAnnotation]?,
        in annotationRect: CGRect,
        on pageView: PSPDFPageView
    ) -> [PSPDFMenuItem] {
        return menuItems.compactMap { item in
            guard item.identifier != PSPDFTextMenu.annotationMenuNote.rawValue else { return nil }
            if item.identifier == PSPDFTextMenu.annotationMenuInspector.rawValue {
                item.title = NSLocalizedString("Style", bundle: .core, comment: "")
            }
            if item.identifier == PSPDFTextMenu.annotationMenuRemove.rawValue {
                return PSPDFMenuItem(title: item.title, image: .icon(.trash), block: item.actionBlock, identifier: item.identifier)
            }
            return item
        }
    }

    public func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        if controller is PSPDFStampViewController { return false }
        if controller is UIActivityViewController {
            _ = try? pdfController.document?.save()
        }
        return true
    }
}
