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

import WebKit

extension CoreWebView {

    /**
     This class handles the resizing operations when a video enters/exits fullscreen mode.
     When fullscreen toggled on or off the system moves the webview between different view
     hierarchies so we have to make sure that the webview gets resized correctly.
     */
    class FullScreenVideoSupport {
        private var fullScreenObservation: NSKeyValueObservation?
        /// These are the constraints the webview had before entered fullscreen mode
        private var originalConstraints: [NSLayoutConstraint]

        public init(webView: WKWebView) {
            originalConstraints = (webView.superview?.constraintsAffecting(view: webView) ?? []) + webView.constraints

            guard #available(iOS 16.0, *) else {
                return
            }

            let matchFullScreenContainerSize: (WKWebView, [NSLayoutConstraint]) -> Void = { webView, constraints in
                constraints.forEach { $0.isActive = false }
                webView.translatesAutoresizingMaskIntoConstraints = true
                webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                webView.frame = webView.superview?.frame ?? .zero
            }
            let restoreOriginalConstraints: (WKWebView, [NSLayoutConstraint]) -> Void = { webView, constraints in
                webView.translatesAutoresizingMaskIntoConstraints = false
                constraints.forEach { $0.isActive = true }
                webView.superview?.layoutIfNeeded()
            }
            fullScreenObservation = webView.observe(\.fullscreenState, options: []) { [originalConstraints] webView, _  in
                switch webView.fullscreenState {
                case .enteringFullscreen:
                    matchFullScreenContainerSize(webView, originalConstraints)
                    // This is to make a11y elements below the fullscreen window hidden.
                    webView.superview?.accessibilityViewIsModal = true
                case .notInFullscreen:
                    restoreOriginalConstraints(webView, originalConstraints)
                default: break
                }
            }
        }
    }
}
