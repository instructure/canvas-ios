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
import Foundation

private class OnAppear: CoreWebViewFeature {
    private let handlerName = "waitForHTMLElement"
    private let script: String
    private let elementId: String
    private let callback: () -> Void

    init(
        elementId: String,
        callback: @escaping () -> Void
    ) {
        self.elementId = elementId
        self.callback = callback
        script = """
            const observer = new MutationObserver(function(mutations) {
                const target = document.getElementById('\(elementId)');
                if (target) {
                    window.webkit.messageHandlers.\(handlerName).postMessage('\(elementId)');
                    observer.disconnect();
                }
            });
            observer.observe(document.documentElement, { childList: true, subtree: true });
        """
    }

    override func apply(on webView: CoreWebView) {
        let expectedMessage = elementId
        webView.handle(handlerName) { [callback] message in
            guard let message = message.body as? String,
                  message == expectedMessage
            else { return }
            callback()
        }
        webView.addScript(script)
    }
}

extension CoreWebViewFeature {
    static func onAppearElement(Id: String, callback: @escaping () -> Void) -> CoreWebViewFeature {
        OnAppear(elementId: Id, callback: callback)
    }
}
