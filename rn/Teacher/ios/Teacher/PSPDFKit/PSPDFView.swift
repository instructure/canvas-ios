//
//  PSPDFView.swift
//  Teacher
//
//  Created by Ben Kraus on 5/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit

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

class PSPDFView: UIView {
    
    weak var pdfViewController: PSPDFViewController?
    
    var config: NSDictionary = [:] {
        didSet {
            setNeedsLayout()
        }
    }
    
    var documentURL: URL? {
        if let url = config["documentURL"] as? String {
            return URL(fileURLWithPath: url)
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if pdfViewController == nil {
            embed()
        } else {
            pdfViewController?.view.frame = bounds
        }
    }
    
    private func embed() {
        guard
            let parentVC = parentViewController,
            let documentURL = documentURL else {
            return
        }
        
        let doc = PSPDFDocument(url: documentURL)
        let vc = PSPDFViewController(document: doc)
        parentVC.addChildViewController(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParentViewController: parentVC)
        self.pdfViewController = vc
    }
}
