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

import Combine
import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    private var handleLink: ((URL) -> Bool)?
    private var handleSize: ((CGFloat) -> Void)?
    private var handleNavigationFinished: (() -> Void)?
    private let source: Source?
    private var customUserAgentName: String?
    private var disableZoom: Bool = false
    private var pullToRefresh: CoreWebView.PullToRefresh
    private var invertColorsInDarkMode: Bool = false
    private var reloadTrigger: AnyPublisher<Void, Never>?
    private var configuration: WKWebViewConfiguration?

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    // MARK: - Initializers

    public init(
        url: URL?,
        pullToRefresh: CoreWebView.PullToRefresh
    ) {
        source = url.map { .request(URLRequest(url: $0)) }
        self.pullToRefresh = pullToRefresh
    }

    public init(
        url: URL?,
        customUserAgentName: String?,
        disableZoom: Bool = false,
        pullToRefresh: CoreWebView.PullToRefresh,
        configuration: WKWebViewConfiguration? = nil,
        invertColorsInDarkMode: Bool = false
    ) {
        self.init(url: url, pullToRefresh: pullToRefresh)
        self.customUserAgentName = customUserAgentName
        self.disableZoom = disableZoom
        self.pullToRefresh = pullToRefresh
        self.invertColorsInDarkMode = invertColorsInDarkMode
        self.configuration = configuration
    }

    public init(html: String?) {
        source = html.map { .html($0) }
        pullToRefresh = .disabled
    }

    public init(
        request: URLRequest,
        disableZoom: Bool = false,
        pullToRefresh: CoreWebView.PullToRefresh
    ) {
        source = .request(request)
        self.disableZoom = disableZoom
        self.pullToRefresh = pullToRefresh
    }

    // MARK: - View Modifiers

    public func onLink(_ handleLink: @escaping (URL) -> Bool) -> Self {
        var modified = self
        modified.handleLink = handleLink
        return modified
    }

    public func onChangeSize(_ handleSize: @escaping (CGFloat) -> Void) -> Self {
        var modified = self
        modified.handleSize = handleSize
        return modified
    }

    public func onNavigationFinished(_ handleNavigationFinished: (() -> Void)?) -> Self {
        var modified = self
        modified.handleNavigationFinished = handleNavigationFinished
        return modified
    }

    public func frameToFit() -> some View {
        FrameToFit(view: self)
    }

    // MARK: - Event Listening

    /**
     This modifier makes the underlying CoreWebView to call its reload() method when the given publisher is signaled.
     */
    public func reload(on trigger: AnyPublisher<Void, Never>) -> Self {
        var modified = self
        modified.reloadTrigger = trigger
        return modified
    }

    // MARK: - UIViewRepresentable Protocol

    public func makeUIView(context: Self.Context) -> CoreWebView {
        CoreWebView(
            customUserAgentName: customUserAgentName,
            disableZoom: disableZoom,
            pullToRefresh: pullToRefresh,
            configuration: configuration,
            invertColorsInDarkMode: invertColorsInDarkMode
        )
    }

    public func updateUIView(_ uiView: CoreWebView, context: Self.Context) {
        uiView.linkDelegate = context.coordinator
        uiView.sizeDelegate = context.coordinator
        context.coordinator.reload(webView: uiView, on: reloadTrigger)

        if context.coordinator.loaded != source {
            context.coordinator.loaded = source
            switch source {
            case .html(let html):
                uiView.loadHTMLString(html)
            case .request(let request):
                uiView.load(request)
            case nil:
                break
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
}

// MARK: - Inner Types

extension WebView {
    enum Source: Equatable {
        case html(String)
        case request(URLRequest)
    }

    private struct FrameToFit: View {
        let view: WebView

        @State var height: CGFloat = 0

        var body: some View {
            view
                .onChangeSize { height in
                    withAnimation { self.height = height }
                }
                .frame(height: height, alignment: .top)
        }
    }

    public class Coordinator: CoreWebViewLinkDelegate, CoreWebViewSizeDelegate {
        var loaded: Source?
        private let view: WebView
        private var reloadObserver: AnyCancellable?

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

        public var routeLinksFrom: UIViewController { view.controller.value }

        public func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat) {
            view.handleSize?(height)
        }

        public func finishedNavigation() {
            view.handleNavigationFinished?()
        }

        public func reload(webView: CoreWebView, on trigger: AnyPublisher<Void, Never>?) {
            reloadObserver?.cancel()
            reloadObserver = trigger?.sink {
                webView.reload()
            }
        }
    }
}
