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

import UIKit

class CanvasLTIPostMessageHandler: CoreWebViewFeature {

    private let script: String? = {
        if let url = Bundle.core.url(forResource: "CanvasLTIPostMessageHandler", withExtension: "js"),
           let jsSource = try? String(contentsOf: url, encoding: .utf8) {
            return jsSource
        }
        return nil
    }()

    public override init() { }

    override func apply(on webView: CoreWebView) {
        if let script {
            webView.addScript(script)
        }
    }
}

public extension CoreWebViewFeature {

    /// This is to be used with webViews that are intended to load content
    /// as HTML string. This important to fix a resize issue with LTI iframes.
    static var canvasLTIPostMessageHandler: CoreWebViewFeature {
        CanvasLTIPostMessageHandler()
    }
}
