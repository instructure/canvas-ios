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

import SwiftUI
import WebKit

extension HorizonUI {

    /// Wraps the custom WKWebView in UIViewRepresentable to make it available for SwiftUI
    public struct MenuActionsWebView: UIViewRepresentable {
        private let htmlString: String
        private let delegate: HorizonUI.MenuActionsWebView.Delegate

        public init(
            htmlString: String,
            delegate: Delegate
        ) {
            self.htmlString = htmlString
            self.delegate = delegate
        }

        public func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.loadHTMLString(htmlString, baseURL: nil)
            return webView
        }

        public func updateUIView(_ uiView: WKWebView, context: Context) {
            uiView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}

/// Methods that our custom WKWebView depends on having implemented
extension HorizonUI.MenuActionsWebView {
    @MainActor
    public protocol Delegate {
        /// Gets the buttons to be displayed to the user when a body of text is selected
        func getMenu(
            webView: WKWebView,
            range: NSRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu

        /// Called when the user taps on the web view
        func onTap(gesture: UITapGestureRecognizer)
    }
}

/// A custom WKWebView for adding the custom buttons when highlighting text
private class MenuActionsWKWebView: WKWebView, WKUIDelegate {

    private let menuActionsWKWebViewDelegate: HorizonUI.MenuActionsWebView.Delegate?

    init(delegate: HorizonUI.MenuActionsWebView.Delegate) {
        self.menuActionsWKWebViewDelegate = delegate

        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.uiDelegate = self

        self.isOpaque = false
        self.backgroundColor = .clear

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))

        DispatchQueue.main.async {
            //on the first pass, the contentSize is incorrect
            //we invalidate the intrinsic content size to cause a recalculation
            self.scrollView.contentSize = CGSize(width: self.frame.width, height: self.scrollView.contentSize.height)
        }
    }

    required init?(coder: NSCoder) {
        self.menuActionsWKWebViewDelegate = nil
        super.init(coder: coder)
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        menuActionsWKWebViewDelegate?.onTap(gesture: gesture)
    }

    // Override method to handle custom menu options
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Custom menu logic can be added here if needed
        return nil
    }

    // Method to create custom menu options when text is highlighted
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let customMenuJS = """
        document.body.addEventListener('contextmenu', function(event) {
            event.preventDefault();
            window.location.href = 'custommenu://' + window.getSelection().toString();
        });
        """
        self.evaluateJavaScript(customMenuJS, completionHandler: nil)
    }

    override var intrinsicContentSize: CGSize {
        return frame.height > 0 ? scrollView.contentSize : super.intrinsicContentSize
    }
}
