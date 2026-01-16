//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import WebKit

private class PullToRefresh: CoreWebViewFeature {
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(refreshWebView(_:)),
            for: .valueChanged
        )
        return refreshControl
    }()
    private weak var webView: CoreWebView?
    private var pullToRefreshNavigation: WKNavigation?

    // MARK: - Public Methods

    override func apply(on webView: CoreWebView) {
        addRefreshControl(to: webView)
        self.webView = webView
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation == pullToRefreshNavigation {
            refreshControl.endRefreshing()
            pullToRefreshNavigation = nil
        }
    }

    // MARK: - Private Methods

    private func addRefreshControl(to webView: CoreWebView) {
        webView.scrollView.refreshControl = refreshControl
        webView.scrollView.bounces = true
    }

    @objc private func refreshWebView(_ sender: UIRefreshControl) {
        guard pullToRefreshNavigation == nil else { return }
        pullToRefreshNavigation = webView?.reload()
    }
}

public extension CoreWebViewFeature {

    static var pullToRefresh: CoreWebViewFeature {
        PullToRefresh()
    }
}
