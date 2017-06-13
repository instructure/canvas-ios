//
//  CanvadocView.swift
//  Teacher
//
//  Created by Ben Kraus on 5/26/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit
import SoAnnotated

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

class NonHideableAnnotationToolbar: PSPDFAnnotationToolbar {
    override var doneButton: UIButton? {
        return nil
    }
}

class CanvadocView: UIView {
    
    weak var pdfViewController: PSPDFViewController?
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let toolbar = UIToolbar()
    private let flexibleToolbarContainer = PSPDFFlexibleToolbarContainer()
    
    var config: Dictionary<String, Any> = [:] {
        didSet {
            pdfViewController = nil
            bringSubview(toFront: activityIndicator)
            activityIndicator.startAnimating()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.hidesWhenStopped = true
        toolbar.autoresizingMask = .flexibleWidth
    }
    required init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if activityIndicator.superview == nil {
            addSubview(activityIndicator)
        }
        
        if pdfViewController == nil {
            loadDocument()
        }
        
        pdfViewController?.view.frame = CGRect(x: 0, y: 33.0, width: bounds.width, height: bounds.height-33.0)
        activityIndicator.frame = CGRect(x: (bounds.width/2)-(activityIndicator.bounds.width/2), y: (bounds.height/2)-(activityIndicator.bounds.height/2), width: activityIndicator.bounds.width, height: activityIndicator.bounds.height)
        toolbar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 33.0)
        flexibleToolbarContainer.frame = bounds
    }
    
    private func embed(pdfViewController: PSPDFViewController) {
        guard let parentVC = parentViewController else { return }
        guard self.pdfViewController == nil else { return }
        
        parentVC.addChildViewController(pdfViewController)
        addSubview(pdfViewController.view)
        pdfViewController.view.frame = CGRect(x: 0, y: 33.0, width: bounds.width, height: bounds.height-33.0)
        pdfViewController.didMove(toParentViewController: parentVC)
        self.pdfViewController = pdfViewController
        
        addSubview(toolbar)
        
        let manager = pdfViewController.annotationStateManager
        let annotationToolbar = NonHideableAnnotationToolbar(annotationStateManager: manager)
        annotationToolbar.supportedToolbarPositions = [.positionInTopBar]
        annotationToolbar.barTintColor = self.tintColor
        annotationToolbar.tintColor = .white
        annotationToolbar.isDragEnabled = false
        
        flexibleToolbarContainer.flexibleToolbar = annotationToolbar
        flexibleToolbarContainer.overlaidBar = toolbar
        addSubview(flexibleToolbarContainer)

        flexibleToolbarContainer.show(animated: true, completion: nil)
    }
    
    
    private func loadDocument() {
        activityIndicator.startAnimating()
        
        let client = CanvasKeymaster.the().currentClient.copy() as! CKIClient
        client.requestSerializer = AFHTTPRequestSerializer()
        client.responseSerializer = AFHTTPResponseSerializer()
        client.requestSerializer.setValue("Bearer \(CanvasKeymaster.the().currentClient.accessToken!)", forHTTPHeaderField: "Authorization")
        client.setTaskWillPerformHTTPRedirectionBlock { (session, task, response, request) in
            
            guard let requestURL = request.url else {
                return request
            }
            
            var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)!
            components.query = nil
            components.path = (components.path as NSString).deletingLastPathComponent
            
            if let goodURL = components.url {
                CanvadocsPDFDocumentPresenter.loadPDFViewController(goodURL, with: teacherAppConfiguration) { (pdfViewController, errors) in
                    if let pdfViewController = pdfViewController as? PSPDFViewController {
                        self.activityIndicator.stopAnimating()
                        self.embed(pdfViewController: pdfViewController)
                    }
                }
            }
            
            return request
        }
        
        client.get(previewPath, parameters: nil, progress: nil, success: { (task, response) in
            // successful load doesn't actually mean anything except the redirect happened
        }) { (task, error) in
            if let response = task?.response as? HTTPURLResponse, response.statusCode != 302 {
                // show an error of some sort
            }
        }
    }
}
