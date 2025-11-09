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

class InsertStudioDetailView: CoreWebViewFeature {

    private let insertScript: String = {
        let title = String(localized: "Open in Detail View", bundle: .core)

        return """
            function insertStudioDetailsLinks() {
                const frameElements = document.querySelectorAll('iframe[data-media-id]');

                frameElements.forEach(elm => {
                    let next = elm.nextElementSibling.nextElementSibling;
                    let wasInjected = next.getAttribute("web-injected");

                    if(wasInjected == 1) { return }

                    const videoTitle = elm.getAttribute("title");
                    var frameLink = elm.getAttribute("src");
                    frameLink = frameLink.replace("media_attachments_iframe", "media_attachments");

                    var linkSuffix = "/immersive_view";
                    if(videoTitle){
                        linkSuffix = "/immersive_view?title=" + encodeURIComponent(videoTitle);
                    }

                    const newLine = document.createElement('br');
                    const newParagraph = document.createElement('p');
                    newParagraph.setAttribute("web-injected", 1);

                    const detailButton = document.createElement('a');
                    detailButton.className = "details_view_link";
                    detailButton.href = frameLink + linkSuffix;
                    detailButton.target = "_detail_view";
                    detailButton.textContent = '\(title)';

                    newParagraph.appendChild(detailButton);

                    elm.insertAdjacentElement('afterend', newLine);
                    newLine.insertAdjacentElement('afterend', newParagraph);
                });
            }

            insertStudioDetailsLinks();
            window.addEventListener("DOMContentLoaded", insertStudioDetailsLinks);
        """
    }()

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(insertScript)
    }
}

public extension CoreWebViewFeature {

    static var insertStudioDetailView: CoreWebViewFeature {
        InsertStudioDetailView()
    }
}
