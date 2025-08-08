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

import SwiftUI
import Core

private class DidSubmitQuiz: CoreWebViewFeature {

    private let eventName = "quiz.submitted"
    private let handlerName = "waitForHTMLElement"
    private let script: String
    private let callback: () -> Void

    public init(callback: @escaping () -> Void) {
        self.callback = callback
        script =
       """
       window.addEventListener("message", (event) => {
         if (event.data && event.data.type === "quiz.resultContentRendered") {
           window.webkit.messageHandlers.\(handlerName).postMessage('\(eventName)');
         }
       });
       """
    }

    override func apply(on webView: CoreWebView) {
        webView.handle(handlerName) { [callback, eventName] message in
            print(message.body)
            guard let message = message.body as? String,
                  message == eventName
            else {
                return
            }
            callback()
        }
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {
    static func onSubmitQuiz(callback: @escaping () -> Void) -> CoreWebViewFeature {
        DidSubmitQuiz(callback: callback)
    }
}
