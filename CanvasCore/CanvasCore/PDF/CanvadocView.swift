//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import React
import Core

// CREDIT: https://stackoverflow.com/a/24590678
extension UIView {
    fileprivate var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

public class CanvadocView: UIView {
    
    @objc weak var pdfViewController: PDFViewController?

    @objc var bottomInset = CGFloat(0.0)
    
    fileprivate let activityIndicator = UIActivityIndicatorView(style: .gray)
    fileprivate let openInButton = UIButton()
    fileprivate var docInteractionController: UIDocumentInteractionController?

    var sessionAPI: API?
    var task: URLSessionTask?
    
    private let toolbar = UIToolbar()
    private let flexibleToolbarContainer = FlexibleToolbarContainer()
    
    @objc var config: Dictionary<String, Any> = [:] {
        didSet {
            if let inset = config["drawerInset"] as? CGFloat {
                bottomInset = inset
            }
            if config["previewPath"] as? String != oldValue["previewPath"] as? String {
                removePDFViewFromView()
                bringSubviewToFront(activityIndicator)
            }
            setNeedsLayout()
        }
    }
    
    @objc var onSaveStateChange: RCTDirectEventBlock?
    
    @objc var previewPath: String {
        if let path = config["previewPath"] as? String {
            return String(path.dropFirst()) // lop off beginning forward slash to avoid dupes
        } else {
            return ""
        }
    }
    
    @objc var fallbackURL: URL? {
        guard let url = config["fallbackURL"] as? String else { return nil}
        return URL(string: url)
    }
    @objc var fallbackLocalURL: URL? = nil
    
    @objc var filename: String? {
        return config["filename"] as? String
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.hidesWhenStopped = true
        toolbar.autoresizingMask = .flexibleWidth
        
        openInButton.setTitle(NSLocalizedString("Open in…", comment: ""), for: .normal)
        openInButton.sizeToFit()
        openInButton.isHidden = true
        openInButton.addTarget(self, action: #selector(openInButtonTapped), for: .touchUpInside)

        if let session = AppEnvironment.shared.currentSession {
            sessionAPI = URLSessionAPI(loginSession: session, urlSession: URLSessionAPI.noFollowRedirectURLSession)
        }
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    deinit {
        if pdfViewController?.parent != nil {
            pdfViewController?.willMove(toParent: nil)
            pdfViewController?.removeFromParent()
        }
        self.pdfViewController?.annotationStateManager.remove(self)
        task?.cancel()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if activityIndicator.superview == nil {
            addSubview(activityIndicator)
        }
        
        if openInButton.superview == nil {
            addSubview(openInButton)
        }
        
        // using the animating prop of the activity indicator as state to determine if we are already trying to load
        if pdfViewController == nil, !activityIndicator.isAnimating {
            loadDocument()
        }
        
        pdfViewController?.view.frame = self.getPDFViewControllerFrame()
        activityIndicator.frame = CGRect(x: (bounds.width/2)-(activityIndicator.bounds.width/2), y: (bounds.height/2)-(activityIndicator.bounds.height/2), width: activityIndicator.bounds.width, height: activityIndicator.bounds.height)
        toolbar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 33.0)
        flexibleToolbarContainer.frame = bounds
        openInButton.center = activityIndicator.center
        
        if let insets = pdfViewController?.configuration.additionalScrollViewFrameInsets, insets.bottom != self.bottomInset {
            pdfViewController?.updateConfigurationWithoutReloading { [weak self] config in
                var updated = insets
                updated.bottom = self?.bottomInset ?? 0.0
                config.additionalScrollViewFrameInsets = updated
            }
        }
    }

    private func embed(pdfViewController: PDFViewController) {
        guard let parentVC = parentViewController else { return }
        guard self.pdfViewController == nil else { return }

        self.pdfViewController = pdfViewController
        parentVC.addChild(pdfViewController)
        addSubview(pdfViewController.view)
        pdfViewController.view.frame = self.getPDFViewControllerFrame()
        pdfViewController.didMove(toParent: parentVC)

        if let presenter = pdfViewController.delegate as? CanvadocsPDFDocumentPresenter, let metadata = presenter.metadata, metadata.annotationMetadata.enabled {
            addSubview(toolbar)
            
            let manager = pdfViewController.annotationStateManager
            let annotationToolbar = CanvadocsAnnotationToolbar(annotationStateManager: manager)
            annotationToolbar.supportedToolbarPositions = [.inTopBar]
            annotationToolbar.isDragEnabled = false
            annotationToolbar.showDoneButton = false

            flexibleToolbarContainer.flexibleToolbar = annotationToolbar
            flexibleToolbarContainer.overlaidBar = toolbar
            addSubview(flexibleToolbarContainer)

            flexibleToolbarContainer.show(animated: true, completion: nil)
            self.pdfViewController?.annotationStateManager.add(self)
        }
    }
    
    private func removePDFViewFromView() {
        toolbar.removeFromSuperview()
        flexibleToolbarContainer.removeFromSuperview()
        pdfViewController?.willMove(toParent: nil)
        pdfViewController?.removeFromParent()
        pdfViewController?.view.removeFromSuperview()
        pdfViewController?.didMove(toParent: nil)
        pdfViewController = nil
    }
    
    private func loadDocument() {
        activityIndicator.startAnimating()
        guard previewPath != "", let url = URL(string: previewPath, relativeTo: sessionAPI?.baseURL) else {
            return downloadFallback()
        }
        let request = URLRequest(url: url)
        task = sessionAPI?.makeRequest(request) { [weak self] _, response, error in
            guard let self = self else { return }
            if let error = error {
                return DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    let dismiss = NSLocalizedString("Dismiss", tableName: nil, bundle: .core, value: "Dismiss", comment: "")
                    alert.addAction(UIAlertAction(title: dismiss, style: .default, handler: nil))
                    UIApplication.shared.delegate?.topViewController?.present(alert, animated: true, completion: nil)
                }
            }
            if let url = (response as? HTTPURLResponse)?.allHeaderFields["Location"] as? String {
                var components = URLComponents.parse(url)
                components.query = nil
                components.path = components.path.replacingOccurrences(of: "/view", with: "")
                if let goodURL = components.url {
                    CanvadocsPDFDocumentPresenter.loadPDFViewController(goodURL, with: teacherAppConfiguration(bottomInset: self.bottomInset), showAnnotationBarButton: true, onSaveStateChange: self.onSaveStateChange) { pdfViewController, errors in
                        if let pdfViewController = pdfViewController as? PDFViewController {
                            self.activityIndicator.stopAnimating()
                            self.embed(pdfViewController: pdfViewController)
                        } else  {
                            self.downloadFallback()
                        }
                    }
                } else {
                    self.downloadFallback()
                }
            } else {
                self.downloadFallback()
            }
        }
    }
    
    private func getPDFViewControllerFrame() -> CGRect {
        var annotationsEnabled = false
        if let vc = pdfViewController, let presenter = vc.delegate as? CanvadocsPDFDocumentPresenter {
            annotationsEnabled = presenter.metadata!.annotationMetadata.enabled
        }
        let offset: CGFloat = 42
        return CGRect(x: 0, y: annotationsEnabled ? offset : 0, width: bounds.width, height: annotationsEnabled ? bounds.height-offset : bounds.height)
    }
    
    fileprivate func setScrollEnabled(_ enabled: Bool) {
        var view = self.superview
        while view != nil {
            if let scrollContainer = view as? RCTScrollView {
                let scrollView = scrollContainer.scrollView
                scrollView?.isScrollEnabled = enabled
            }
            view = view?.superview
        }
    }
    
    fileprivate func downloadFallback() {
        guard let fallbackURL = self.fallbackURL else { return }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: fallbackURL)
        task.resume()
    }
    
    @objc func openInButtonTapped() {
        guard let fallbackLocalURL = fallbackLocalURL else { return }
        
        docInteractionController = UIDocumentInteractionController(url: fallbackLocalURL)
        docInteractionController?.delegate = self
        docInteractionController?.presentOpenInMenu(from: openInButton.frame, in: self, animated: true)
    }
    
    @objc public func syncAnnotations() {
        guard let presenter = pdfViewController?.delegate as? CanvadocsPDFDocumentPresenter else { return }
        presenter.annotationProvider?.syncAllAnnotations()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let controller = pdfViewController else { return }
        let parent = parentViewController
        parent?.addChild(controller)
        controller.didMove(toParent: parent)
    }

    public override func removeFromSuperview() {
        pdfViewController?.dismiss(animated: false) // avoid orphan popovers
        super.removeFromSuperview()
    }
}

extension CanvadocView: AnnotationStateManagerDelegate {
    public func annotationStateManager(_ manager: AnnotationStateManager, didChangeState oldState: Annotation.Tool?, to newState: Annotation.Tool?, variant oldVariant: Annotation.Variant?, to newVariant: Annotation.Variant?) {
        if let state = newState, !state.rawValue.isEmpty {
            setScrollEnabled(false)
        } else {
            setScrollEnabled(true)
        }
    }
}

extension CanvadocView: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let filename = self.filename {
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: fileURL.relativePath) {
                let _ = try? FileManager.default.removeItem(at: fileURL)
            }
            
            do {
                try FileManager.default.copyItem(at: location, to: fileURL)
            } catch (let writeError) {
                print("error writing file \(fileURL): \(writeError)")
            }
            
            self.fallbackLocalURL = fileURL
            
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.openInButton.isHidden = false
            }
        }
    }
}

extension CanvadocView: UIDocumentInteractionControllerDelegate {}
