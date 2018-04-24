//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import PSPDFKit
import PSPDFKitUI
import React
import CanvasKeymaster
import AFNetworking

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

// swift should just provide these...
private func == <T>(lhs: T?, rhs: T?) -> Bool where T: Equatable {
    switch (lhs, rhs) {
    case (.none, .none):            return true
    case (.none, _), (_, .none):    return false
    case let (.some(l), .some(r)):  return l == r
    default:                        return false
    }
}

private func != <T>(lhs: T?, rhs: T?) -> Bool where T: Equatable {
    return !(lhs == rhs)
}

public class CanvadocView: UIView {
    
    weak var pdfViewController: PSPDFViewController?
    var bottomInset = CGFloat(0.0)
    
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate let openInButton = UIButton()
    fileprivate var docInteractionController: UIDocumentInteractionController?
    
    private let toolbar = UIToolbar()
    private let flexibleToolbarContainer = PSPDFFlexibleToolbarContainer()
    
    var config: Dictionary<String, Any> = [:] {
        didSet {
            if let inset = config["drawerInset"] as? CGFloat {
                bottomInset = inset
            }
            if config["previewPath"] as? String != oldValue["previewPath"] as? String {
                removePDFViewFromView()
                bringSubview(toFront: activityIndicator)
            }
            setNeedsLayout()
        }
    }
    
    var previewPath: String {
        if let path = config["previewPath"] as? String {
            return path.substring(from: path.index(path.startIndex, offsetBy: 1)) // lop off beginning forward slash to avoid dupes
        } else {
            return ""
        }
    }
    
    var fallbackURL: URL? {
        guard let url = config["fallbackURL"] as? String else { return nil}
        return URL(string: url)
    }
    var fallbackLocalURL: URL? = nil
    
    var filename: String? {
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
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    deinit {
        self.pdfViewController?.annotationStateManager.remove(self)
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
    
    private func embed(pdfViewController: PSPDFViewController) {
        guard let parentVC = parentViewController else { return }
        guard self.pdfViewController == nil else { return }
        
        parentVC.addChildViewController(pdfViewController)
        addSubview(pdfViewController.view)
        pdfViewController.view.frame = self.getPDFViewControllerFrame()
        pdfViewController.didMove(toParentViewController: parentVC)
        self.pdfViewController = pdfViewController
        
        if let presenter = pdfViewController.delegate as? CanvadocsPDFDocumentPresenter, let metadata = presenter.metadata, metadata.annotationMetadata.enabled {
            addSubview(toolbar)
            
            let manager = pdfViewController.annotationStateManager
            let annotationToolbar = CanvadocsAnnotationToolbar(annotationStateManager: manager)
            annotationToolbar.supportedToolbarPositions = [.positionInTopBar]
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
        pdfViewController?.willMove(toParentViewController: nil)
        pdfViewController?.removeFromParentViewController()
        pdfViewController?.view.removeFromSuperview()
        pdfViewController?.didMove(toParentViewController: nil)
        pdfViewController = nil
    }
    
    private func loadDocument() {
        activityIndicator.startAnimating()
        
        guard previewPath != "" else { downloadFallback(); return }
        
        guard let client = CanvasKeymaster.the().currentClient?.copy() as? CKIClient, let accessToken = CanvasKeymaster.the().currentClient?.accessToken else { return }
        client.requestSerializer = AFHTTPRequestSerializer()
        client.responseSerializer = AFHTTPResponseSerializer()
        client.requestSerializer.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        client.setTaskWillPerformHTTPRedirectionBlock { [weak self] (session, task, response, request) in
            
            guard let requestURL = request.url, let me = self else {
                return request
            }
            
            var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)!
            components.query = nil
            components.path = (components.path as NSString).deletingLastPathComponent
            
            if let goodURL = components.url {
                CanvadocsPDFDocumentPresenter.loadPDFViewController(goodURL, with: teacherAppConfiguration(bottomInset: me.bottomInset)) { [weak self] (pdfViewController, errors) in
                    if let pdfViewController = pdfViewController as? PSPDFViewController {
                        self?.activityIndicator.stopAnimating()
                        self?.embed(pdfViewController: pdfViewController)
                    } else  {
                        self?.downloadFallback()
                    }
                }
            }
            
            return request
        }
        
        var params = Dictionary<String, String>()
        if let actAsUser = client.actAsUserID {
            params["as_user_id"] = actAsUser
        }
        client.get(previewPath, parameters: params, progress: nil, success: { (task, response) in
            // successful load doesn't actually mean anything except the redirect happened
        }) { (task, error) in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                let dismiss = NSLocalizedString("Dismiss", tableName: nil, bundle: .core, value: "Dismiss", comment: "")
                alert.addAction(UIAlertAction(title: dismiss, style: .default, handler: nil))
                UIApplication.shared.delegate?.topViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func getPDFViewControllerFrame() -> CGRect {
        var annotationsEnabled = false
        if let vc = pdfViewController, let presenter = vc.delegate as? CanvadocsPDFDocumentPresenter {
            annotationsEnabled = presenter.metadata!.annotationMetadata.enabled
        }
        return CGRect(x: 0, y: annotationsEnabled ? 33.0 : 0, width: bounds.width, height: annotationsEnabled ? bounds.height-33.0 : bounds.height)
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
    
    func openInButtonTapped() {
        guard let fallbackLocalURL = fallbackLocalURL else { return }
        
        docInteractionController = UIDocumentInteractionController(url: fallbackLocalURL)
        docInteractionController?.delegate = self
        docInteractionController?.presentOpenInMenu(from: openInButton.frame, in: self, animated: true)
    }
}

extension CanvadocView: PSPDFAnnotationStateManagerDelegate {
    public func annotationStateManager(_ manager: PSPDFAnnotationStateManager, didChangeState oldState: AnnotationString?, to newState: AnnotationString?, variant oldVariant: AnnotationString?, to newVariant: AnnotationString?) {
        if let _ = newState {
            setScrollEnabled(false)
        } else {
            setScrollEnabled(true)
        }
    }
}

extension CanvadocView: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let filename = self.filename, let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = caches.appendingPathComponent(filename)
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

extension CanvadocView: UIDocumentInteractionControllerDelegate { }
