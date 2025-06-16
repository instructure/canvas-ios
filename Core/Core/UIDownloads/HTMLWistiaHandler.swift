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

import SwiftSoup
import UIKit

public struct HTMLWistiaHandler {
    public static func updateWistia(in html: String?, courseID: String?, moduleItemID: String?) -> String? {
        guard let html = html else { return nil }
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let usualTranscriptHeight: Int = 285
        let shortenTranscriptHeight: Int = 175
        var wistiaIDs: [String] = []
        do {
            let document = try SwiftSoup.parse(html)
            let iframes = try document.getElementsByTag("iframe")
            for iframe in iframes {
                let src = try iframe.attr("src")
                if isWistiaLink(src) {
                    let styleValue = try? iframe.attr("style")

                    if let id = getWistiaId(from: src) {
                        wistiaIDs.append(id)
                        var stringToReplace: String = ""
                        let currentHTML = try document.html()
                        let v1Link = "https://fast.wistia.com/assets/external/E-v1.js"
                        if !currentHTML.contains(v1Link) {
                            stringToReplace += "<script src=\"\(v1Link)\" async></script>"
                        }

                        if !currentHTML.contains(highlightDarkCSS) {
                            stringToReplace += highlightDarkCSS
                        }

                        let transcriptLink: String = "https://fast.wistia.net/assets/external/transcript.js"
                        if !currentHTML.contains(transcriptLink) {
                            stringToReplace += "<script src=\"\(transcriptLink)\" async></script>"
                        }

                        stringToReplace += """
                        <script src="https://fast.wistia.com/embed/medias/\(id).jsonp" async></script>
                        <div class="wistia_embed wistia_async_\(id)"
                        style = \"width:100%; height:100%; \(styleValue ?? "")\">&nbsp;</div>
                        """

                        let wistiaTranscriptionTag = "<wistia-transcript media-id=\"\(id)\" style=\"margin-top: 20px;height:\(usualTranscriptHeight)px;\"></wistia-transcript>"
                        if let parent = iframe.parent(),
                            try parent.attr("class") == "wistia_responsive_wrapper",
                            let parentOfParent = parent.parent(),
                            try parentOfParent.attr("class") == "wistia_responsive_padding" {
                            try parentOfParent.after(wistiaTranscriptionTag)
                        } else {
                            stringToReplace += wistiaTranscriptionTag
                        }

                        let div = try document.createElement("div")
                        try div.attr("style", "width:100%;height:100%")
                        try div.append(stringToReplace)
                        try iframe.replaceWith(div)
                    }
                }
            }
            var html = try document.html()
            if isPad {
                html += """
                <script>
                    var vpHeight = window.visualViewport.height;
                    var vpWidth = window.visualViewport.width;
                    setTranscriptsHeight(vpHeight > vpWidth);
                    function setTranscriptsHeight(isPortrait) {
                        document.querySelectorAll('wistia-transcript')
                            .forEach((transcriptTag) => {
                                if (isPortrait) {
                                    transcriptTag.style.height = "\(usualTranscriptHeight)px";
                                } else {
                                    transcriptTag.style.height = "\(shortenTranscriptHeight)px";
                                }
                            });
                    };
                    window.matchMedia("(orientation: portrait)").addEventListener("change", e => {
                        const portrait = e.matches;
                        setTranscriptsHeight(portrait);
                    });
                </script>
                """
            }
            html += wistiaPlayerAnalyticsScript(
                wistiaIDs: wistiaIDs,
                courseID: courseID ?? "",
                userID: AppEnvironment.shared.currentSession?.userID ?? "",
                moduleItemID: moduleItemID
            )
            return html
        } catch {

        }
        return nil
    }

    // swiftlint:disable:next function_body_length
    private static func wistiaPlayerAnalyticsScript(
        wistiaIDs: [String],
        courseID: String,
        userID: String,
        moduleItemID: String?
    ) -> String {
        guard wistiaIDs.count > 0 else {
            return ""
        }
        var moduleItemParamString: String
        if let moduleItemID = moduleItemID {
            moduleItemParamString = "module_item_id: \"\(moduleItemID)\","
        } else {
            moduleItemParamString = ""
        }

        return """
        <script type='text/javascript'>
            const wistiaIDs = [\(wistiaIDs.map { "\"\($0)\"" }.joined(separator: ", "))];
            // Add listeners for video player
            async function addListenerForWistia(player, wistiaID) {
                const csrf_token = await loadCSRF();
                const watchedPercents = new Set();

                player.addEventListener('timeupdate', () => {
                    const percent = Math.floor((player.currentTime / player.duration) * 100);

                    // For every 5%
                    for (let p = 5; p <= 100; p += 5) {
                        if (percent >= p && !watchedPercents.has(p)) {
                            watchedPercents.add(p);
                            sendWatchedTime(
                                {
                                    watched_percentage: p,
                                    course_id: "###COURSE_ID###",
                                    user_id: "###USER_ID###",
                                    wistia_media_id: wistiaID,
                                    ###MODULE_ITEM_ID_PARAM_STRING###
                                },
                                csrf_token
                            );
                        }
                    }
                });
            }
            function waitForWistiaVideoPlayer(wistiaID, callback, interval = 200) {
                const checkPlayer = setInterval(() => {
                    const videos = document.getElementsByTagName('video');
                    var wistiaPlayer = null;
                    for (const video of videos) {
                        if (video.innerHTML.includes(wistiaID)) {
                            wistiaPlayer = video;
                            break;
                        }
                    }
                    if (wistiaPlayer) {
                        clearInterval(checkPlayer);
                        callback(wistiaPlayer, wistiaID);
                    }
                }, interval);
            }
            !(function () {
                setTimeout(
                    function() {
                        for (const id of wistiaIDs) {
                            waitForWistiaVideoPlayer(
                                id,
                                function(player, wistiaID) {
                                    addListenerForWistia(player, wistiaID);
                                }
                            );
                        }
                    },
                    1500
                );
            })();

            // Load Token
            async function loadCSRF() {
                const response = await fetch(
                    `https://canvas-analytics-lti.prod.oc.2u.com/wistia/csrf`,
                    {
                        credentials: "include",
                    }
                );
                const data = await response.json();
                return data.csrfToken;
            }

            // Send Analytic Event
            function sendWatchedTime(payload, token) {
                const formData = new FormData();

                Object.entries(payload).forEach(([key, value]) => {
                    formData.append(key, value);
                });

                formData.append("csrfmiddlewaretoken", token);

                fetch(
                    `https://canvas-analytics-lti.prod.oc.2u.com/wistia/video/user/activity`,
                    {
                        method: "POST",
                        credentials: "include",
                        body: formData,
                    }
                ).catch((error) => console.error("Error:", error));
            }
        </script>
        """
            .replacingOccurrences(of: "###MODULE_ITEM_ID_PARAM_STRING###", with: moduleItemParamString)
            .replacingOccurrences(of: "###COURSE_ID###", with: courseID)
            .replacingOccurrences(of: "###USER_ID###", with: userID)
    }

    static func isWistiaLink(_ link: String) -> Bool {
        link.contains("wistia") &&
        link.contains("iframe") &&
        link.contains("embed")
    }

    static func getWistiaId(from link: String) -> String? {
        if isWistiaLink(link),
            let url = URL(string: link) {

            let components = url.pathComponents

            var isNextIsId = false
            for component in components {
                if isNextIsId {
                    return component
                }

                if component == "iframe" {
                    isNextIsId = true
                }
            }
        }
        return nil
    }

    static var highlightDarkCSS: String {
        """
        <style>
            @media (prefers-color-scheme: dark) {
                wistia-transcript::part(current-cue) {
                    background-color: rgba(94, 98, 113, 1) !important;
                }
            }
        </style>
        """
    }
}
