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
        private var originalUserInterfaceStyle: UIUserInterfaceStyle?
        private weak var originalSuperview: UIView?

        public init(webView: WKWebView) {
            originalSuperview = webView.superview
            originalConstraints = (webView.superview?.constraintsAffecting(view: webView) ?? []) + webView.constraints
            fullScreenObservation = webView.observe(\.fullscreenState, options: []) { [weak self] webView, _  in
                guard let self else { return }

                switch webView.fullscreenState {
                case .enteringFullscreen:
                    matchFullScreenContainerSize(webView)
                    hideA11yElementsBelowFullscreenWindow(webView)
                    setupDarkBackground(webView)
                    disableColorInversion(webView)
                    self.webView = webView
                case .notInFullscreen:
                    restoreOriginalConstraints(webView)
                    restoreBackground(webView)
                    restoreColorInversion(webView)
                    self.webView = nil
                default: break
                }
            }
        }

        private func matchFullScreenContainerSize(_ webView: WKWebView) {
            originalConstraints.forEach { $0.isActive = false }
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            guard let superview = webView.superview else {
                webView.frame = .zero
                return
            }

            let superviewBounds = superview.bounds
            let safeAreaInsets = superview.safeAreaInsets

            webView.frame = CGRect(
                x: -safeAreaInsets.left,
                y: -safeAreaInsets.top,
                width: superviewBounds.width + safeAreaInsets.left + safeAreaInsets.right,
                height: superviewBounds.height + safeAreaInsets.top + safeAreaInsets.bottom
            )
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

            /// This is a walk-around for an issue that occurs on iOS 26, where
            /// webView doesn't get moved back to the original superview upon
            /// exiting fullScreen mode.
            if let originalSuperview, originalSuperview !== webView.superview {
                webView.removeFromSuperview()
                originalSuperview.addSubview(webView)
            }

            guard let superview = webView.superview else { return }

            // Stop the video from keep playing when rotating the screen
            pauseVideo(in: webView)

            webView.pin(inside: superview)
            webView.superview?.layoutIfNeeded()
        }

        private func pauseVideo(in webView: WKWebView) {
            let pauseScript = """
            (function() {
                var videos = document.querySelectorAll('video');
                videos.forEach(function(video) {
                    video.pause();
                });
            })();
            """
            webView.evaluateJavaScript(pauseScript)
        }

        private func restoreBackground(_ webView: WKWebView) {
            webView.backgroundColor = originalWebViewBackgroundColor
        }

        // Otherwise in dark mode, the colors of the video get inverted
        private func disableColorInversion(_ webView: WKWebView) {
            originalUserInterfaceStyle = webView.overrideUserInterfaceStyle
            webView.overrideUserInterfaceStyle = .light
        }

        private func restoreColorInversion(_ webView: WKWebView) {
            if let originalStyle = originalUserInterfaceStyle {
                webView.overrideUserInterfaceStyle = originalStyle
            }
        }
    }
}
