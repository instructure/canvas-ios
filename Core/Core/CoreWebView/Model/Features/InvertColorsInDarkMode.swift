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

private class InvertColorsInDarkMode: CoreWebViewFeature {
    private let script: String = {
        let darkCss = """
        @media (prefers-color-scheme: dark) {
            html {
                filter: invert(100%) hue-rotate(180deg);
            }
            img:not(.ignore-color-scheme), video:not(.ignore-color-scheme), .ignore-color-scheme {
                filter: invert(100%) hue-rotate(180deg) !important;
            }
        }
        """

        let cssString = darkCss.components(separatedBy: .newlines).joined()
        return """
           var element = document.createElement('style');
           element.innerHTML = '\(cssString)';
           document.head.appendChild(element);
        """
    }()

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {

    /**
     This feature injects a javascript into the webview that inverts colors on the loaded website.
     Useful if we load 3rd party content without dark mode support.
     */
    static var invertColorsInDarkMode: CoreWebViewFeature {
        InvertColorsInDarkMode()
    }
}
