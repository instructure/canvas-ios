//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public typealias MessageHandler = (WKScriptMessage) -> Void

extension WKWebView {
    public func addScript(_ js: String, injectionTime: WKUserScriptInjectionTime = .atDocumentEnd) {
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }

    public func handle(_ name: String, handler: @escaping MessageHandler) {
        let passer = MessagePasser(handler: handler)
        configuration.userContentController.add(passer, name: name)
    }
}

private class MessagePasser: NSObject, WKScriptMessageHandler {
    let handler: MessageHandler

    init(handler: @escaping MessageHandler) {
        self.handler = handler
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler(message)
    }
}
