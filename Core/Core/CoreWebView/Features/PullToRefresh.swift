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

public class PullToRefresh: CoreWebViewFeature {
    public enum State {
        case disabled
        case enabled(color: UIColor?)
    }

    private lazy var refreshControl: CircleRefreshControl = {
        let refreshControl = CircleRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(refreshWebView(_:)),
            for: .valueChanged
        )
        return refreshControl
    }()
    private let state: State
    private weak var webView: CoreWebView?
    private var pullToRefreshNavigation: WKNavigation?

    // MARK: - Public Methods

    public init(state: State) {
        self.state = state
    }

    public override func apply(on webView: CoreWebView) {
        if case let .enabled(color) = state {
            addRefreshControl(color: color, to: webView)
            self.webView = webView
        }
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation == pullToRefreshNavigation {
            refreshControl.endRefreshing()
            pullToRefreshNavigation = nil
        }
    }

    // MARK: - Private Methods

    private func addRefreshControl(color: UIColor?, to webView: CoreWebView) {
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        refreshControl.color = color
    }

    @objc private func refreshWebView(_ sender: UIRefreshControl) {
        guard pullToRefreshNavigation == nil else { return }
        pullToRefreshNavigation = webView?.reload()
    }
}
