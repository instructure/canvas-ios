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
        /// If no one is keeping a strong reference to the webview it will deallocate after moving to full screen.
        private var webView: WKWebView?
        /// These are the constraints the webview had before entered fullscreen mode
        private var originalConstraints: [NSLayoutConstraint]
        private var originalWebViewBackgroundColor: UIColor?

        public init(webView: WKWebView) {
            originalConstraints = (webView.superview?.constraintsAffecting(view: webView) ?? []) + webView.constraints

            guard #available(iOS 16.0, *) else {
                return
            }

            fullScreenObservation = webView.observe(\.fullscreenState, options: []) { [weak self] webView, _  in
                guard let self else { return }

                switch webView.fullscreenState {
                case .enteringFullscreen:
                    matchFullScreenContainerSize(webView)
                    hideA11yElementsBelowFullscreenWindow(webView)
                    setupDarkBackground(webView)
                    self.webView = webView
                case .notInFullscreen:
                    restoreOriginalConstraints(webView)
                    restoreBackground(webView)
                    self.webView = nil
                default: break
                }
            }
        }

        private func matchFullScreenContainerSize(_ webView: WKWebView) {
            originalConstraints.forEach { $0.isActive = false }
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.frame = webView.superview?.frame ?? .zero
        }

        private func hideA11yElementsBelowFullscreenWindow(_ webView: WKWebView) {
            webView.superview?.accessibilityViewIsModal = true
        }

        private func setupDarkBackground(_ webView: WKWebView) {
            originalWebViewBackgroundColor = webView.backgroundColor
            webView.backgroundColor = .black
        }

        private func restoreOriginalConstraints(_ webView: WKWebView) {
            webView.translatesAutoresizingMaskIntoConstraints = false
            originalConstraints.forEach { $0.isActive = true }
            webView.superview?.layoutIfNeeded()
        }

        private func restoreBackground(_ webView: WKWebView) {
            webView.backgroundColor = originalWebViewBackgroundColor
        }
    }
}
