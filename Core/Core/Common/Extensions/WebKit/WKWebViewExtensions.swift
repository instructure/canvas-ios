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

import Combine
import WebKit

public typealias MessageHandler = (WKScriptMessage) -> Void

public extension WKWebView {

    func addScript(_ js: String, injectionTime: WKUserScriptInjectionTime = .atDocumentEnd) {
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }

    func handle(_ name: String, handler: @escaping MessageHandler) {
        let passer = MessagePasser(handler: handler)
        configuration.userContentController.removeScriptMessageHandler(forName: name)
        configuration.userContentController.add(passer, name: name)
    }

    func evaluateJavaScript(js: String) -> AnyPublisher<Any, Error> {
        Future { promise in
            self.evaluateJavaScript(js) { result, error in
                if let result {
                    promise(.success(result))
                } else {
                    promise(.failure(error ?? NSError.internalError()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// The returned publisher finishes when the webView's `isLoading` property turns to false
    /// and is still false after `checkInterval`.
    func waitUntilLoadFinishes(
        checkInterval: TimeInterval
    ) -> AnyPublisher<Void, Never> {
        Timer.publish(every: checkInterval, on: .main, in: .common)
            .autoconnect()
            .map { _ in self.isLoading }
            .pairwise()
            .first { (previousLoading, newLoading) in
                newLoading == false && previousLoading == previousLoading
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

public class MessagePasser: NSObject, WKScriptMessageHandler {
    let handler: MessageHandler

    public init(handler: @escaping MessageHandler) {
        self.handler = handler
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler(message)
    }
}
