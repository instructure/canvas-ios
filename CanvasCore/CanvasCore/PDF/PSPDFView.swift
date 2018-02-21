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
    required public init?(coder aDecoder: NSCoder) { fatalError("nope") }
    
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
        
        let doc = PSPDFDocument(url: documentURL)
        let vc = PSPDFViewController(document: doc)
        parentVC.addChildViewController(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParentViewController: parentVC)
        self.pdfViewController = vc
    }
}
