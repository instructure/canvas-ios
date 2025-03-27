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

import Core

private class BackButton: CoreWebViewFeature {
    private let handlerName = "buttonTapped"
    private let script: String
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback

        self.script =
            """
            document.addEventListener('click', function(event) {
                var element = event.target;
                while (element) {
                    if (element.id === 'ios-inbox-back-button') {
                        window.webkit.messageHandlers.buttonTapped.postMessage(element.innerText);
                        break;
                    }
                    element = element.parentElement;
                }
            });
            """
    }

    override func apply(on webView: CoreWebView) {
        webView.handle(handlerName) { [callback] _ in
            callback()
        }

        webView.addScript(script)
    }
}

extension CoreWebViewFeature {
    static func onTapBackButton(callback: @escaping () -> Void) -> CoreWebViewFeature {
        BackButton(callback: callback)
    }
}
