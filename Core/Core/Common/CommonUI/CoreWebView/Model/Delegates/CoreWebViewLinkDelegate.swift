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

public protocol CoreWebViewLinkDelegate: AnyObject {
    var routeLinksFrom: UIViewController { get }

    /// Gives the option to opt-out of this behavior on specific screen if needed
    var allowsExternalToolsLinks: Bool { get }

    func handleLink(_ url: URL) -> Bool
    func finishedNavigation()
    func coreWebView(_ webView: CoreWebView, didStartProvisionalNavigation navigation: WKNavigation!)

    func coreWebView(_ webView: CoreWebView, didStartDownloadAttachment attachment: CoreWebAttachment)
    func coreWebView(_ webView: CoreWebView, didFailAttachmentDownload attachment: CoreWebAttachment, with error: any Error)
    func coreWebView(_ webView: CoreWebView, didFinishAttachmentDownload attachment: CoreWebAttachment)
}

extension CoreWebViewLinkDelegate {
    public func finishedNavigation() {}
    public func coreWebView(_ webView: CoreWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}

    public func coreWebView(_ webView: CoreWebView, didStartDownloadAttachment attachment: CoreWebAttachment) {}
    public func coreWebView(_ webView: CoreWebView, didFailAttachmentDownload attachment: CoreWebAttachment, with error: any Error) {}
    public func coreWebView(_ webView: CoreWebView, didFinishAttachmentDownload attachment: CoreWebAttachment) {}
}

// MARK: - Routing

extension CoreWebViewLinkDelegate {

    public var allowsExternalToolsLinks: Bool { true }

    public func route(in env: AppEnvironment, to url: String, options: RouteOptions = Router.DefaultRouteOptions) {
        route(in: env, to: .parse(url), options: options)
    }

    public func route(in env: AppEnvironment, to url: URL, options: RouteOptions = Router.DefaultRouteOptions) {
        route(in: env, to: .parse(url), options: options)
    }

    public func route(
        in env: AppEnvironment,
        to url: URLComponents,
        options: RouteOptions = Router.DefaultRouteOptions
    ) {
        env.router.route(to: url, from: routeLinksFrom, options: options)
    }
}

// MARK: - Links Handling

extension CoreWebViewLinkDelegate where Self: UIViewController {
    public func handleLink(_ url: URL) -> Bool {
        route(in: .shared, to: url)
        return true
    }
    public var routeLinksFrom: UIViewController { self }
}
