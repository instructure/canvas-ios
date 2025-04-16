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
import Combine
import WebKit
import Observation

@Observable
final class HEmbeddedWebPageContainerViewModel {
    // MARK: - Outputs

    private(set) var url: URL?
    let navTitle: String
    private(set) var webViewConfiguration: WKWebViewConfiguration?
    private var subscriptions: Set<AnyCancellable> = []

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

        let cookieValues = [
            "log_session_id":"150be26a41acaa25b61d545606722aef", "_legacy_normandy_session":"Z3uis8bh9_AGwOLDsxUxZA.idcv-c_3Rd14vFApOL1R5t8Y3vzzUgJR_-hKT49-hyIT6qnWJCDhDfhR8SvdyPxxsu1Znw6NNqKDN6pp8a2u8_9IKptxK42-_nPTbPOFkHKJ8E-lWYlldreauOKo9p41.vUGAN3g0G-Bz_23f6ATvDlVyj_k.Z_7v7g", "canvas_session":API.canvasSessionToken ?? "", "_csrf_token":"8z7ezwrAedCkaW8gAxullX00AlmdhH9w%2B7BVSrAUaXuQe4qrSKMphOcmGBJFKs7bP0JgL9juNjea1CAzgXEgEw%3D%3D"
        ]

        let configuration: WKWebViewConfiguration = .defaultConfiguration
        configuration.applyDefaultSettings()

        let futures = cookieValues.keys.compactMap { key in
            if let cookie = HTTPCookie(
                properties: [
                    .name: key,
                    .value: cookieValues[key] ?? "",
                    .domain: "pd.canvasforcareer.com",
                    .path: "/",
                    .expires: Date(timeIntervalSinceNow: 31536000)
                ]
            ) {
                return configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
            return nil
        }

        Task {
            await withTaskGroup(of: Void.self) { group in
                for future in futures {
                    group.addTask {
                        await future
                    }
                }

                for await _ in group {}
            }
            DispatchQueue.main.async { [weak self] in
                self?.webViewConfiguration = configuration
            }
        }
    }

    // MARK: - Private Functions

    private func constructURL(from webPage: EmbeddedWebPageViewModel) -> URL? {
        var baseURL = AppEnvironment.shared.currentSession?.baseURL
        baseURL = replaceInstructureWithCanvasForCareer(baseURL: baseURL)
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webPage.webView(
            webView,
            didStartProvisionalNavigation: navigation
        )
    }

    private func replaceInstructureWithCanvasForCareer(baseURL: URL?) -> URL? {
        guard let baseURL = baseURL else { return nil }
        let urlString = baseURL.absoluteString.replacingOccurrences(of: "instructure.com", with: "canvasforcareer.com")
        return URL(string: urlString)
    }
}
