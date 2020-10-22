//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

public struct WebView: UIViewRepresentable {
    enum Source: Equatable {
        case html(String)
        case url(URL)
    }

    var handleLink: ((URL) -> Bool)?
    var handleSize: ((CoreWebView, CGFloat) -> Void)?
    let source: Source?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var loaded: Source?

    public init(url: URL?) {
        source = url.map { .url($0) }
    }

    public init(html: String?) {
        source = html.map { .html($0) }
    }

    public func onLink(_ handleLink: @escaping (URL) -> Bool) -> Self {
        var modified = self
        modified.handleLink = handleLink
        return modified
    }

    public func onChangeSize(_ handleSize: @escaping (CoreWebView, CGFloat) -> Void) -> Self {
        var modified = self
        modified.handleSize = handleSize
        return modified
    }

    public func makeUIView(context: Self.Context) -> CoreWebView {
        CoreWebView()
    }

    public func updateUIView(_ uiView: CoreWebView, context: Self.Context) {
        uiView.linkDelegate = context.coordinator
        uiView.sizeDelegate = context.coordinator
        if loaded != source {
            loaded = source
            switch source {
            case .html(let html):
                uiView.loadHTMLString(html)
            case .url(let url):
                uiView.load(URLRequest(url: url))
            case nil:
                break
            }
        }
    }

    public class Coordinator: CoreWebViewLinkDelegate, CoreWebViewSizeDelegate {
        let view: WebView

        init(view: WebView) {
            self.view = view
        }

        public func handleLink(_ url: URL) -> Bool {
            if let handleLink = view.handleLink {
                return handleLink(url)
            }
            view.env.router.route(to: url, from: routeLinksFrom)
            return true
        }

        public var routeLinksFrom: UIViewController { view.controller }

        public func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat) {
            view.handleSize?(webView, height)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
}
