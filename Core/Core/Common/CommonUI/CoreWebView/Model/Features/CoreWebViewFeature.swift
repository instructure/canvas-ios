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

/**
 This is an abstract class for a webview feature.
 Methods here should be overridden and the necessary changes should be made there to make the custom feature work.
 */
open class CoreWebViewFeature {
    public init() {}
    open func apply(on configuration: WKWebViewConfiguration) {}
    open func apply(on webView: CoreWebView) {}
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}
