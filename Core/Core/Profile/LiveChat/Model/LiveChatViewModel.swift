//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

enum ChatBotType {
    case five9
    case xpert
}

enum WKScriptEvent: String {
    case closeChat
    case openChat
    case shouldOpenFive9
}

class LiveChatViewModel: ObservableObject {
    @Published var currentChatType: ChatBotType = .xpert
    @Published var hideWebviewWhileLoading: Bool = true
    @Published var isDisplaying: Bool = true

    var userName: String = ""
    var userEmail: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""

    var appID: String {
        return "2U DEV" // TODO: change when go to PROD
//        return "2U Inc"
    }

    private let env = AppEnvironment.shared
    lazy var profile = env.subscribe(GetUserProfile(userID: "self")) { [weak self] in
        self?.profileUpdated()
    }

    init() {
        profile.refresh()
    }

    func profileUpdated() {
        guard let profile = profile.first else { return }
        userName = profile.name
        userEmail = profile.email ?? ""
        // split name on first and last names
        var components = userName.components(separatedBy: " ")
        if components.count > 0 {
            userFirstName = components.removeFirst()
            userLastName = components.joined(separator: " ")
        }
    }

    private var configID: String {
        RemoteConfigManager.shared.five9ConfigID
    }

    private var formadataLabel: String {
        RemoteConfigManager.shared.formadataLabel
    }

    private var chatSegmentKey: String {
        RemoteConfigManager.shared.segmentKey
    }

    private var xpertKey: String {
        RemoteConfigManager.shared.xpertKey
    }

    var formDataString: String {
        """
        [
            {
                "type": "hidden",
                "formType": "both",
                "required": false
            },
            {
                "label": "First Name",
                "cav": "contact.firstName",
                "formType": "both",
                "type": "text",
                "required": true,
                "readOnly": false,
                "value": "###FIRSTNAME###"
            },
            {
                "label": "Last Name",
                "cav": "contact.lastName",
                "formType": "both",
                "type": "text",
                "required": true,
                "readOnly": false,
                "value": "###LASTNAME###"
            },
            {
                "type": "hidden",
                "formType": "both",
                "required": false
            },
            {
                "label": "University Email or Email Address on Record",
                "cav": "contact.email",
                "formType": "both",
                "type": "email",
                "required": true,
                "value": "###EMAIL###"
            },
            {
                "type": "hidden",
                "formType": "both",
                "required": false
            },
            {
                "label": "Question/Describe your Issue",
                "cav": "Question",
                "formType": "both",
                "type": "textarea",
                "required": true,
                "readOnly": false
            },
            {
                "type": "hidden",
                "formType": "both",
                "required": false
            },
            {
                "type": "static text",
                "formType": "both",
                "required": false,
                "label": '###LABEL###'
            }
        ]
        """
            .replacingOccurrences(of: "###FIRSTNAME###", with: userFirstName)
            .replacingOccurrences(of: "###LASTNAME###", with: userLastName)
            .replacingOccurrences(of: "###EMAIL###", with: userEmail)
            .replacingOccurrences(of: "###LABEL###", with: formadataLabel)
    }

    var five9HTML: String {
        // swiftlint:disable line_length
        """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, \
                viewport-fit=cover">
            </head>
            <body>
                <script src="https://live-chat.ps.five9.com/Five9ChatPlugin.js" type="text/javascript"></script>
                <script>
                    function callback(event) {
                        try {
                            switch (event.type) {
                            case 'initialized':
                                window.webkit.messageHandlers.###openChat###.postMessage("###openChat###");
                                break;
                            case 'error':
                                if (event.error == "No active chat session") {
                                    window.webkit.messageHandlers.###closeChat###.postMessage("###closeChat###");
                                }
                                break;
                            case 'endChatConfirmed':
                                window.webkit.messageHandlers.###closeChat###.postMessage("###closeChat###");
                                break;
                            default:
                                break;
                        }
                        } catch (exception) {}
                    }
                    let options = {
                        "appId": "###APPID###",
                        "configId": "###CONFIGID###",
                        "headless": true,
                        "startOpen": true,
                        "allowAttachments": false,
                        "allowPopout": false,
                        "hideMinimize": true,
                        "miniForm": true,
                        "subtitle": "Hello, ###NAME###",
                        "contact": {
                            "email": "###EMAIL###",
                            "name": "###NAME###"
                        },
                        "sendButtonText": "<img src='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTYuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4IiB2aWV3Qm94PSIwIDAgNTM1LjUgNTM1LjUiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDUzNS41IDUzNS41OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+CjxnPgoJPGcgaWQ9InNlbmQiPgoJCTxwb2x5Z29uIHBvaW50cz0iMCw0OTcuMjUgNTM1LjUsMjY3Ljc1IDAsMzguMjUgMCwyMTYuNzUgMzgyLjUsMjY3Ljc1IDAsMzE4Ljc1ICAgIiBmaWxsPSIjY2JjYmNiIi8+Cgk8L2c+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPC9zdmc+Cg==' class='rcw-send-icon' alt='Send'>",
                        "sendButtonActiveText": "<img src='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTYuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4IiB2aWV3Qm94PSIwIDAgNTM1LjUgNTM1LjUiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDUzNS41IDUzNS41OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+CjxnPgoJPGcgaWQ9InNlbmQiPgoJCTxwb2x5Z29uIHBvaW50cz0iMCw0OTcuMjUgNTM1LjUsMjY3Ljc1IDAsMzguMjUgMCwyMTYuNzUgMzgyLjUsMjY3Ljc1IDAsMzE4Ljc1ICAgIiBmaWxsPSIjY2JjYmNiIi8+Cgk8L2c+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPGc+CjwvZz4KPC9zdmc+Cg==' class='rcw-send-icon' alt='Send' style='filter: contrast(0)' >",
                        "formData": ###FORMDATA###
                    };
                    options.callback = callback;
                    Five9ChatPlugin(options);
                </script>
            </body>
        </html>
        """
            .replacingOccurrences(of: "###NAME###", with: userName)
            .replacingOccurrences(of: "###EMAIL###", with: userEmail)
            .replacingOccurrences(of: "###CONFIGID###", with: configID)
            .replacingOccurrences(of: "###FORMDATA###", with: formDataString)
            .replacingOccurrences(of: "###APPID###", with: appID)
            .replacingOccurrences(of: "###openChat###", with: WKScriptEvent.openChat.rawValue)
            .replacingOccurrences(of: "###closeChat###", with: WKScriptEvent.closeChat.rawValue)
    }

    var xpertHTML: String {
        """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, \
                viewport-fit=cover">
                <link rel="stylesheet" href="https://chatbot-frontend.prod.ai.2u.com/@latest/index.min.css" />
                <style type="text/css">
                    .intercom-lightweight-app-launcher {
                        display: none !important;
                    }
                </style>
            </head>
            <body>
                <script>
                    const formData = ###FORMDATA###;
                    window.XpertChatbotFrontend = {
                        xpertKey: '###XPERTKEY###',
                        configurations: {
                            chatApi: {
                                payloadParams: {
                                    use_case: 'Canvas_Student',
                                },
                            },
                            conversationScreen: {
                                liveChat: {
                                    options: {
                                        appId: '###APPID###',
                                        configId: '###CONFIGID###',
                                        formData: formData,
                                    },
                                },
                            },
                        },
                    };
                </script>
                <script type="module" src="https://chatbot-frontend.prod.ai.2u.com/@latest/index.min.js"></script>
                <script>
                !function(){var i="analytics",analytics=window[i]=window[i]||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","reset","group","track","ready","alias","debug","page","screen","once","off","on","addSourceMiddleware","addIntegrationMiddleware","setAnonymousId","addDestinationMiddleware","register"];analytics.factory=function(e){return function(){if(window[i].initialized)return window[i][e].apply(window[i],arguments);var n=Array.prototype.slice.call(arguments);if(["track","screen","alias","group","page","identify"].indexOf(e)>-1){var c=document.querySelector("link[rel='canonical']");n.push({__t:"bpc",c:c&&c.getAttribute("href")||void 0,p:location.pathname,u:location.href,s:location.search,t:document.title,r:document.referrer})}n.unshift(e);analytics.push(n);return analytics}};for(var n=0;n<analytics.methods.length;n++){var key=analytics.methods[n];    analytics[key]=analytics.factory(key)}analytics.load=function(key,n){var t=document.createElement("script");t.type="text/javascript";t.async=!0;t.setAttribute("data-global-segment-analytics-key",i);t.src="https://cdn.segment.com/analytics.js/v1/" + key + "/analytics.min.js";var r=document.getElementsByTagName("script")[0];r.parentNode.insertBefore(t,    r);analytics._loadOptions=n};analytics._writeKey="###SEGMENTKEY###";;analytics.SNIPPET_VERSION="5.2.0";
                    analytics.load("###SEGMENTKEY###");
                    analytics.page();
                }}();
                </script>
                <script>
                    document.addEventListener(
                        "DOMSubtreeModified",
                        function(e) {
                            var container = document.getElementById("xpert-chatbot-container");
                            if (container != undefined) {
                                var button = container.getElementsByTagName("button")[0];
                                if (button != undefined && button.isClicked == undefined) {
                                    setTimeout(() => {
                                        button.click();
                                        window.webkit.messageHandlers.###openChat###.postMessage("###openChat###");
                                    }, 500);
                                    button.isClicked = true;
                                }
                            }
                            var xpertCloseButton = document.getElementsByClassName("xpert-chatbot-popup__header--btn-outline")[0]
                            if (xpertCloseButton != undefined) {
                                xpertCloseButton.addEventListener(
                                    "click",
                                    function(e) {
                                        window.webkit.messageHandlers.###closeChat###.postMessage("###closeChat###");
                                    },
                                    false
                                );
                            }
                            var five9OpenButton = document.getElementsByClassName("xpert-chatbot-popup__live-chat--btn-outline")[0]
                            if (five9OpenButton != undefined) {
                                five9OpenButton.addEventListener(
                                    "click",
                                    function(e) {
                                        window.webkit.messageHandlers.###shouldOpenFive9###.postMessage("###shouldOpenFive9###");
                                    },
                                    false
                                );
                            }
                        },
                        false
                    );
                </script>
            </body>
        </html>
        """
            .replacingOccurrences(of: "###FORMDATA###", with: formDataString)
            .replacingOccurrences(of: "###CONFIGID###", with: configID)
            .replacingOccurrences(of: "###SEGMENTKEY###", with: chatSegmentKey)
            .replacingOccurrences(of: "###APPID###", with: appID)
            .replacingOccurrences(of: "###XPERTKEY###", with: xpertKey)
            .replacingOccurrences(of: "###shouldOpenFive9###", with: WKScriptEvent.shouldOpenFive9.rawValue)
            .replacingOccurrences(of: "###openChat###", with: WKScriptEvent.openChat.rawValue)
            .replacingOccurrences(of: "###closeChat###", with: WKScriptEvent.closeChat.rawValue)
        // swiftlint:enable line_length
    }

    func shouldOpenFive9Event() {
        currentChatType = .five9
        hideWebviewWhileLoading = true
    }
    func openChatEvent() {
        hideWebviewWhileLoading = false
    }
    func closeChatEvent() {
        isDisplaying = false
    }

    var wkEvents: [String: () -> Void] {
        [
            WKScriptEvent.shouldOpenFive9.rawValue: shouldOpenFive9Event,
            WKScriptEvent.openChat.rawValue: openChatEvent,
            WKScriptEvent.closeChat.rawValue: closeChatEvent,
        ]
    }
}
