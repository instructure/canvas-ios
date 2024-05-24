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
struct HTMLWistiaHandler {
    func updateWistia(in html: String) -> String? {
        var result: String = html
        do {
            let document = try SwiftSoup.parse(html)
            let iframes = try document.getElementsByTag("iframe")
            for iframe in iframes {
                let src = try iframe.attr("src")
                if src.contains("wistia") {
                    let styleValue = try? iframe.attr("style")

                    if let id = getWistiaId(from: src) {
                        let stringToReplace = """
                        <script src="//fast.wistia.com/assets/external/E-v1.js" async></script>
                        <script src="//fast.wistia.com/embed/medias/\(id).jsonp" async></script>
                        <div class="wistia_embed wistia_async_\(id)"
                        style = \"width:100%; height:100%; \(styleValue ?? "")\">&nbsp;</div>
                        <script src="https://fast.wistia.net/assets/external/transcript.js" async=""></script>
                        <wistia-transcript media-id="\(id)" style="margin-top: 20px;height:200px;"></wistia-transcript>
                        """
                        result = result.replacingOccurrences(of: try iframe.outerHtml(), with: stringToReplace)
                    }
                }
            }
            return result
        } catch {

        }
        return nil
    }

    func getWistiaId(from link: String) -> String? {
        if link.contains("wistia"), let url = URL(string: link) {
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
}
