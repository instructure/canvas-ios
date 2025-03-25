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
    private(set) var configuration: WKWebViewConfiguration = .defaultConfiguration
    
    // MARK: - Dependencies

    private let webPage: EmbeddedWebPageViewModel
    private weak var navigationDelegate: EmbeddedWebPageNavigation?
    private let javaScript: String?
    private let observeKey: String?
    var viewController: WeakViewController = .init()

    // MARK: - Init

    init(
        webPage: EmbeddedWebPageViewModel,
        navigationDelegate: EmbeddedWebPageNavigation? = nil,
        javaScript: String? = nil,
        observeKey: String? = nil
    ) {
        self.webPage = webPage
        self.navigationDelegate = navigationDelegate
        self.navTitle = webPage.navigationBarTitle
        self.javaScript = javaScript
        self.observeKey = observeKey
        self.url = constructURL(from: webPage)

        if let javaScript, let observeKey {
            addObservation(javaScript: javaScript, observeKey: observeKey)
        }
    }

    private func addObservation(javaScript js: String, observeKey: String) {
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        handle(observeKey) { [weak self] message in
            guard let self else {
                return
            }
            self.navigationDelegate?.observer(scriptMessage: message, viewController: self.viewController)
        }
    }

    private func handle(_ name: String, handler: @escaping MessageHandler) {
         let passer = MessagePasser(handler: handler)
         configuration.userContentController.removeScriptMessageHandler(forName: name)
         configuration.userContentController.add(passer, name: name)
     }

    // MARK: - Private Functions

    private func constructURL(from webPage: EmbeddedWebPageViewModel) -> URL? {
        var baseURL = URL(string: "https://dev.cd.canvashorizon.com")
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!, viewController: WeakViewController) {
        self.viewController = viewController
        webPage.webView(
            webView,
            didStartProvisionalNavigation: navigation
        )
    }
}
