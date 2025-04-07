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
    public static func updateWistia(in html: String?) -> String? {
        guard let html = html else { return nil }
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let usualTranscriptHeight: Int = 285
        let shortenTranscriptHeight: Int = 175
        do {
            let document = try SwiftSoup.parse(html)
            let iframes = try document.getElementsByTag("iframe")
            for iframe in iframes {
                let src = try iframe.attr("src")
                if isWistiaLink(src) {
                    let styleValue = try? iframe.attr("style")

                    if let id = getWistiaId(from: src) {
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
            return html
        } catch {

        }
        return nil
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
