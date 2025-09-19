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

private class LoadGiveFeedback: CoreWebViewFeature {
    private let eventName = "giveFeed.submitted"
    private let handlerName = "cancelFeedbackDialog"
    private let scriptId = "jira-issue-collector"
    // swiftlint:disable:next line_length
    private let scriptSrc = ""

    private let script: String
    private let callback: () -> Void

    public init(callback: @escaping () -> Void) {
        self.callback = callback
        script = """
        const SCRIPT_ID = "\(scriptId)";
        const script = document.createElement("script");
        script.id = SCRIPT_ID;
        script.src = "\(scriptSrc)";
        script.addEventListener("load", function() {
            window.ATL_JQ_PAGE_PROPS = {
                triggerFunction: function (showCollectorDialog) {
                    setTimeout(function() {
                        showCollectorDialog();
                    }, 100);
                }
            };
        });

        document.body.appendChild(script);

        window.addEventListener('message', (event) => {
            if (event.data === '\(handlerName)') {
                window.webkit.messageHandlers.\(handlerName).postMessage('\(eventName)');
            }
        });
        """
    }

    override func apply(on webView: CoreWebView) {
        webView.handle(handlerName) { [callback, eventName] message in
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
    static func onLoadFeedback(callback: @escaping () -> Void) -> CoreWebViewFeature {
        LoadGiveFeedback(callback: callback)
    }
}
