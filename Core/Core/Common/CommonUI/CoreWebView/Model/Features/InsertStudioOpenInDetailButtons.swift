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

class InsertStudioOpenInDetailButtons: CoreWebViewFeature {

    private let insertValues: String = {
        let title = String(localized: "Open in Detail View", bundle: .core)
        let iconSVG = (NSDataAsset(name: "externalLinkData", bundle: .core)
            .flatMap({ String(data: $0.data, encoding: .utf8) ?? "" }) ?? "")
            .components(separatedBy: .newlines).joined()

        return """
            window.detailLinkSpecs = {
                iconSVG: \(CoreWebView.jsString(iconSVG)),
                title: \(CoreWebView.jsString(title))
            }
        """
    }()

    private let insertScript: String? = {
        if let url = Bundle.core.url(forResource: "InsertStudioOpenInDetailButtons", withExtension: "js"),
           let jsSource = try? String(contentsOf: url, encoding: .utf8) {
            return jsSource
        }

        return nil
    }()

    private let insertStyle: String? = {
        if let url = Bundle.core.url(forResource: "InsertStudioOpenInDetailButtons", withExtension: "css"),
           let cssSource = try? String(contentsOf: url, encoding: .utf8) {

            return """
                (() => {
                    var element = document.createElement('style');
                    element.innerHTML = \(CoreWebView.jsString(cssSource));
                    document.head.appendChild(element);
                })()
            """
        }

        return nil
    }()

    public override init() { }

    override func apply(on webView: CoreWebView) {
        webView.addScript(insertValues)

        if let insertStyle {
            webView.addScript(insertStyle)
        }
        if let insertScript {
            webView.addScript(insertScript)
        }
    }

    override func remove(from webView: CoreWebView) {
        webView.removeScript(insertValues)

        if let insertStyle {
            webView.removeScript(insertStyle)
        }
        if let insertScript {
            webView.removeScript(insertScript)
        }
    }
}

public extension CoreWebViewFeature {

    static var insertStudioOpenInDetailButtons: CoreWebViewFeature {
        InsertStudioOpenInDetailButtons()
    }
}
