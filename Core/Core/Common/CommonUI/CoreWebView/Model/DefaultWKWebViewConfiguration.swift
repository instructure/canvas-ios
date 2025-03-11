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

public extension WKWebViewConfiguration {

    static var defaultConfiguration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.applyDefaultSettings()
        return configuration
    }

    func applyDefaultSettings() {
        if #available(iOS 17, *) {
            // iOS 16 has issues with the webview's content size
            // after exiting fullscreen mode so we allow only iOS 17
            preferences.isElementFullscreenEnabled = true
        }
        allowsInlineMediaPlayback = true
        allowsPictureInPictureMediaPlayback = true
        allowsAirPlayForMediaPlayback = true
        processPool = CoreWebView.processPool

        // This is to make -webkit-text-size-adjust work on iPads.
        // https://trac.webkit.org/changeset/261940/webkit
        defaultWebpagePreferences.preferredContentMode = .mobile
    }
}
