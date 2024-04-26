//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct ImageWrapperWebView: UIViewRepresentable {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private let url: URL?

    // MARK: - Initializers

    public init(url: URL?) {
        self.url = url
    }

    // MARK: - UIViewRepresentable Protocol

    public func makeUIView(context: Self.Context) -> UIView {
        let webViewContainer = UIView()
        let webView = ImageWrapperUIKitWebView()
        webViewContainer.addSubview(webView)
        webView.pin(inside: webViewContainer)

        webView.isUserInteractionEnabled = false

        return webViewContainer
    }

    public func updateUIView(_ uiView: UIView, context: Self.Context) {
        guard let webView = uiView.subviews.first(where: { $0 is ImageWrapperUIKitWebView }) as? ImageWrapperUIKitWebView else { return }

        if context.coordinator.loaded != url {
            context.coordinator.loaded = url
            if let url {
                webView.loadImageURL(url, fill: true, restrictZoom: true)
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
}

// MARK: - Inner Types

extension ImageWrapperWebView {
    public class Coordinator {
        var loaded: URL?
        private let view: ImageWrapperWebView

        init(view: ImageWrapperWebView) {
            self.view = view
        }
    }
}

#if DEBUG

struct ImageWrapperWebView_Previews: PreviewProvider {
    static var previews: some View {
        ImageWrapperWebView(url: nil)
            .border(Color.red, width: 1)
    }
}

#endif

public final class ImageWrapperUIKitWebView: WKWebView {
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init() {
        super.init(frame: .zero, configuration: .defaultConfiguration)
        setup()
    }

    private func setup() {
        isOpaque = false
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
    }

    public func loadImageURL(
        _ imageURL: URL,
        baseURL: URL? = AppEnvironment.shared.currentSession?.baseURL,
        fill: Bool,
        restrictZoom: Bool
    ) {
        var html = ""

        if restrictZoom {
            html += """
                <meta name="viewport" content="initial-scale=1, minimum-scale=1, maximum-scale=1" />
            """
        }

        html += """
            <body style="
                margin: 0px; height: 100%; \
                -webkit-user-select: none; \
                ">\
                <img src="\(imageURL)" style="
                    margin: auto; padding: 0px; height: 100%; width: 100%; display: block; \
                    object-fit: \(fill ? "cover" : "contain"); \
                    -webkit-user-select: none; \
                    -webkit-user-drag: none; \
                    -webkit-touch-callout: none; \
                    ">\
            </body>
        """

        loadHTMLString(html, baseURL: baseURL)
    }
}
