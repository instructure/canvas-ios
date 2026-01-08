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

    private let insertStyle: String = {
        let fontSize = UIFont.scaledNamedFont(.regular14).pointSize
        let css = """
        p[ios-injected] {
            text-align: center;
        }

        .open_details_button {
            font-weight: 400;
            font-size: \(fontSize)px;
            text-decoration: none;
            color: #2B7ABC;
        }

        .open_details_button_icon {
            display: inline-block;
            width: 1.3em;
            height: 100%;
            vertical-align: middle;
            padding-right: 0.43em;
            padding-left: 0.43em;
        }

        div.open_details_button_icon svg {
            width: 100%;
            height: auto;
            display: block;
            transform: translate(0, -2px);
        }

        div.open_details_button_icon svg * {
          width: 100%;
          height: 100%;
        }
        """

        let cssString = css.components(separatedBy: .newlines).joined()
        return """
           (() => {
                var element = document.createElement('style');
                element.innerHTML = '\(cssString)';
                document.head.appendChild(element);
           })()
        """
    }()

    private let insertScript: String? = {
        if let url = Bundle.core.url(forResource: "InsertStudioOpenInDetailButtons", withExtension: "js"),
           let jsSource = try? String(contentsOf: url, encoding: .utf8) {
            return jsSource
        }
        return nil
    }()

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

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(insertStyle)

        if let insertScript {
            webView.addScript(insertValues)
            webView.addScript(insertScript)
        }
    }

    override func remove(from webView: CoreWebView) {
        webView.removeScript(insertStyle)

        if let insertScript {
            webView.removeScript(insertValues)
            webView.removeScript(insertScript)
        }
    }
}

public extension CoreWebViewFeature {

    static var insertStudioOpenInDetailButtons: CoreWebViewFeature {
        InsertStudioOpenInDetailButtons()
    }
}
