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

import class Core.AppEnvironment
import class Core.Router
import SwiftUI
import WebKit

class ScriptHandler: NSObject, WKScriptMessageHandler {
    private let dismiss: () -> Void
    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body as? String == "cancelFeedbackDialog" {
            dismiss()
        }
    }
}

struct ProblemReportWebView: UIViewRepresentable {

    @Environment(\.viewController) private var controller

    private let router: Router
    init(router: Router = AppEnvironment.shared.router) {
        self.router = router
    }

    func makeUIView(context: Context) -> WKWebView {
        let script =    """
            var script = document.createElement('script');
            script.src = 'https://instructure.atlassian.net/s/d41d8cd98f00b204e9800998ecf8427e-T/vf1kch/b/0/c95134bc67d3a521bb3f4331beb9b804/_/download/batch/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector.js?locale=en-US&collectorId=e6b73300';
            script.type = 'text/javascript';
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
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let contentController = WKUserContentController()
        let scriptHandler = ScriptHandler {
            router.pop(from: controller)
        }
        contentController.add(scriptHandler, name: "scriptHandler")
        contentController.addUserScript(userScript)

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        return WKWebView(frame: CGRect.zero, configuration: webViewConfiguration)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                div#atlwdg-blanket {
                    opacity: 0 !important;
                }
                div#atlwdg-container {
                    width: 100%;
                    max-height: 100%;
                    height: 100%;
                }
            </style>
          </head>
          <body>
            <script type="text/javascript">
                window.addEventListener('message', (event) => {
                    window.webkit.messageHandlers.scriptHandler.postMessage(event.data);
                });
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
            </script>
          </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
