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

    var webViewConfig: WKWebViewConfiguration { .defaultConfiguration }
    let url: URL
    let navTitle: String

    // MARK: - Dependencies

   private let webPageModel: EmbeddedWebPageViewModel

    // MARK: - Init

    init(webPageModel: EmbeddedWebPageViewModel) {
        self.webPageModel = webPageModel
        self.navTitle = webPageModel.navigationBarTitle
        self.url = {
            guard var baseURL = URL(string: "https://dev.cd.canvashorizon.com") else {
                return URL(string: "/")! // should never happen
            }

            baseURL.appendPathComponent(webPageModel.urlPathComponent)
            baseURL.append(queryItems: webPageModel.queryItems)
            baseURL.append(queryItems: [
                URLQueryItem(name: "embed", value: "true"),
                URLQueryItem(name: "session_timezone", value: TimeZone.current.identifier),
                URLQueryItem(name: "session_locale", value: Locale.current.identifier.replacingOccurrences(of: "_", with: "-"))
            ])

            return baseURL
        }()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webPageModel.webView(
            webView,
            didStartProvisionalNavigation: navigation
        )
    }
}
