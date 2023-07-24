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

import Foundation

private class OnElementAppear: CoreWebViewFeature {
    private let eventName = "elementDidAppear"
    private let handlerName = "waitForHTMLElement"
    private let script: String
    private let elementId: String
    private let callback: () -> Void

    public init(elementId: String, callback: @escaping () -> Void) {
        self.elementId = elementId
        self.callback = callback
        script =
        """
            var element = document.getElementById('\(elementId)')
            if (element) {
                window.webkit.messageHandlers.\(handlerName).postMessage('\(eventName)-\(elementId)')
            }
        """
    }

    override func apply(on webView: CoreWebView) {
        let expectedMessage = "\(eventName)-\(elementId)"
        webView.handle(handlerName) { [callback] message in
            guard let message = message.body as? String,
                  message == expectedMessage
            else {
                return
            }
            callback()
        }
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {

    /**
     - parameters:
        - elementId: The element id that returns an element if passed to `document.getElementById` javascript function.
        - callback: The block to be executed when the given element id is found.
     */
    static func onAppear(elementId: String, callback: @escaping () -> Void) -> CoreWebViewFeature {
        OnElementAppear(elementId: elementId, callback: callback)
    }
}
