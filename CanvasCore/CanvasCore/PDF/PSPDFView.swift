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

public class PSPDFView: UIView {
    
    @objc weak var pdfViewController: PDFViewController?
    
    @objc var config: NSDictionary = [:] {
        didSet {
            setNeedsLayout()
        }
    }
    
    @objc var documentURL: URL? {
        if let url = config["documentURL"] as? String {
            return URL(fileURLWithPath: url)
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("nope") }

    deinit {
        if pdfViewController?.parent != nil {
            pdfViewController?.willMove(toParent: nil)
            pdfViewController?.removeFromParent()
        }
    }
    
    override public func layoutSubviews() {
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
        stylePSPDFKit()

        let doc = Document(url: documentURL)
        let vc = PDFViewController(document: doc)
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        self.pdfViewController = vc
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
