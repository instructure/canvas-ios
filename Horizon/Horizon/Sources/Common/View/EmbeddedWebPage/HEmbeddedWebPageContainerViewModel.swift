//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation
import Core
import WebKit
import Observation

@Observable
final class HEmbeddedWebPageContainerViewModel {
    // MARK: - Outputs

    private(set) var url: URL?
    let navTitle: String

    // MARK: - Dependencies

    private let webPage: EmbeddedWebPageViewModel
    private weak var navigationDelegate: EmbeddedWebPageNavigation?

    // MARK: - Init

    init(
        webPage: EmbeddedWebPageViewModel,
        navigationDelegate: EmbeddedWebPageNavigation? = nil
    ) {
        self.webPage = webPage
        self.navigationDelegate = navigationDelegate
        self.navTitle = webPage.navigationBarTitle
        self.url = constructURL(from: webPage)
    }

    // MARK: - Private Functions

    private func constructURL(from webPage: EmbeddedWebPageViewModel) -> URL? {
        var baseURL = AppEnvironment.shared.currentSession?.baseURL
        baseURL = baseURL?.replaceHostWithCanvasForCareer()
        baseURL?.appendPathComponent(webPage.urlPathComponent)
        baseURL?.append(queryItems: webPage.queryItems)
        baseURL?.append(queryItems: [
            URLQueryItem(name: "embedded", value: "true")
        ])

        return baseURL
    }

    // MARK: - Actions Functions

    func openURL(_ url: URL, viewController: WeakViewController) {
        navigationDelegate?.openURL(url, viewController: viewController)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {        webPage.webView(
            webView,
            didStartProvisionalNavigation: navigation
        )
    }
}
