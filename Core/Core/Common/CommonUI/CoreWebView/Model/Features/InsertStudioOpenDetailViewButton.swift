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

import UIKit

class InsertStudioOpenInDetailButtons: CoreWebViewFeature {

    private let insertStyle: String = {
        let fontSize = UIFont.scaledNamedFont(.regular14).pointSize
        let css = """
        p[ios-injected] {
            text-align: center;
        }

        .open_details_button {
            font-weight: 400;
            font-size: \(fontSize)px;
            text-decoration: none;
            color: #2B7ABC;
        }

        .open_details_button_icon {
            display: inline-block;
            width: 1.3em;
            height: 100%;
            vertical-align: middle;
            padding-right: 0.43em;
            padding-left: 0.43em;
        }

        div.open_details_button_icon svg {
            width: 100%;
            height: auto;
            display: block;
            transform: translate(0, -2px);
        }

        div.open_details_button_icon svg * {
          width: 100%;
          height: 100%;
        }
        """

        let cssString = css.components(separatedBy: .newlines).joined()
        return """
           (() => {
                var element = document.createElement('style');
                element.innerHTML = '\(cssString)';
                document.head.appendChild(element);
           })()
        """
    }()

    private let insertScript: String = {
        let title = String(localized: "Open in Detail View", bundle: .core)
        let iconSVG = (NSDataAsset(name: "externalLinkData", bundle: .core)
            .flatMap({ String(data: $0.data, encoding: .utf8) ?? "" }) ?? "")
            .components(separatedBy: .newlines).joined()

        return """
            function escapeHTML(text) {
                return text
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/'/g, '&#039;')
                    .replace(/"/g, '&quot;')
            }

            function findCanvasUploadLink(elm, title) {
                if (elm.hasAttribute("data-media-id") == false) { return null }

                let frameSource = elm.getAttribute("src");
                if (!frameSource) { return null }

                let frameFullPath = frameSource
                    .replace("/media_attachments_iframe/", "/media_attachments/")

                try {

                    let frameURL = new URL(frameFullPath);
                    frameURL.pathname += "/immersive_view";

                    if (title) {
                        title = title.replace("Video player for ", "").replace(".mp4", "");
                        frameURL.searchParams.set("title", encodeURIComponent(title));
                    }

                    return frameURL;
                } catch {
                    return null;
                }
            }

            function insertStudioDetailsLinks() {
                const frameElements = document.querySelectorAll('iframe[data-media-id]');

                frameElements.forEach(elm => {
                    let nextSibling = elm.nextElementSibling;
                    let nextNextSibling = (nextSibling) ? nextSibling.nextElementSibling : null;
                    let wasInjected = (nextNextSibling) ? nextNextSibling.getAttribute("ios-injected") : 0;

                    if(wasInjected == 1) { return }

                    const videoTitle = elm.getAttribute("title");
                    const ariaTitle = elm.getAttribute("aria-title");

                    let title = videoTitle ?? ariaTitle;
                    let frameLink = findCanvasUploadLink(elm, title);

                    const newLine = document.createElement('br');
                    const newParagraph = document.createElement('p');
                    newParagraph.setAttribute("ios-injected", 1);

                    const buttonContainer = document.createElement('div');
                    buttonContainer.className = "open_detail_button_container";

                    const icon = document.createElement('div');
                    icon.className = "open_details_button_icon";
                    icon.innerHTML = \(CoreWebView.jsString(iconSVG));

                    const detailButton = document.createElement('a');
                    detailButton.className = "open_details_button";
                    detailButton.href = frameLink;
                    detailButton.target = "_blank";
                    detailButton.textContent = escapeHTML(\(CoreWebView.jsString(title)));

                    buttonContainer.appendChild(icon);
                    buttonContainer.appendChild(detailButton);
                    newParagraph.appendChild(buttonContainer);

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
        webView.addScript(insertStyle)
        webView.addScript(insertScript)
    }

    override func remove(from webView: CoreWebView) {
        webView.removeScript(insertStyle)
        webView.removeScript(insertScript)
    }
}

public extension CoreWebViewFeature {

    static var insertStudioOpenInDetailButtons: CoreWebViewFeature {
        InsertStudioOpenInDetailButtons()
    }
}
