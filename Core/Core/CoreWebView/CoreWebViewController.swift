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

import UIKit

public class CoreWebViewController: UIViewController, CoreWebViewLinkDelegate {
    public var webView: CoreWebView

    var limitedInteractionView: NotificationView?

    public var isInteractionLimited: Bool = false {
        didSet {
            webView.isLinkNavigationEnabled = !isInteractionLimited
            webView.allowsLinkPreview = !isInteractionLimited
        }
    }

    /**
     - parameters:
        - invertColorsInDarkMode: If this parameter is true, then the webview will inject a script that inverts colors on the loaded website. Useful if we load 3rd party content without dark mode support.
     */
    public init(invertColorsInDarkMode: Bool = false) {
        webView = CoreWebView(features: invertColorsInDarkMode ? [.invertColorsInDarkMode] : [])
        super.init(nibName: nil, bundle: nil)
        webView.linkDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.pin(inside: view)

        if isInteractionLimited {
            setupLimitedInteractionNotification()
        }
    }

    func setupLimitedInteractionNotification() {
        let n = NotificationView()
        n.messageLabel.text = NSLocalizedString("Interactions on this page are limited by your institution.", bundle: .core, comment: "")
        n.showDismiss = true
        n.dismissHandler = { [weak self] in
            self?.limitedInteractionView?.removeFromSuperview()
        }
        n.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(n)

        NSLayoutConstraint.activate([
            n.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            n.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            n.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            n.heightAnchor.constraint(greaterThanOrEqualToConstant: 78),
        ])
        limitedInteractionView = n
    }
}
