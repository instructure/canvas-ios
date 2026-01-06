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

function findLtiEmbedLink(elm, title) {
    let frameSource = elm.getAttribute("src");
    if(!frameSource) { return null }

    try {

        let frameURL = new URL(frameSource);
        let playerSource = frameURL.searchParams.get("url");
        if(!playerSource) { return null }

        let playerURL = new URL(playerSource);

        let mediaID = playerURL.searchParams.get("custom_arc_media_id");
        let launchType = playerURL.searchParams.get("custom_arc_launch_type");

        if(launchType == "quiz_embed") { return null }
        if(!mediaID) { return null }

        playerURL.searchParams.set("custom_arc_launch_type", "immersive_view");

        frameURL.searchParams.set("url", playerURL.toString());
        frameURL.searchParams.set("display", "full_width");

        if(title) {
            title = title.replace("Video player for ", "").replace(".mp4", "");
            frameURL.searchParams.set("title", encodeURIComponent(title));
        }

        return frameURL;

    } catch {
        return null;
    }
}

function insertDetailsLinks(elm, method) {
    var linkSpecs = window.detailLinkSpecs;
    linkSpecs = (linkSpecs) ? linkSpecs : { iconSVG: null, title: null };

    let nextSibling = elm.nextElementSibling;
    let nextNextSibling = (nextSibling) ? nextSibling.nextElementSibling : null;
    let wasInjected = (nextNextSibling) ? nextNextSibling.getAttribute("ios-injected") : 0;

    if(wasInjected == 1) { return }

    const videoTitle = elm.getAttribute("title");
    const ariaTitle = elm.getAttribute("aria-title");
    const title = videoTitle ?? ariaTitle;

    var buttonHref;
    if(method == "lti") {
        buttonHref = findLtiEmbedLink(elm, title);
    } else {
        buttonHref = findCanvasUploadLink(elm, title);
    }

    if(!buttonHref) { return }

    const newLine = document.createElement('br');
    const newParagraph = document.createElement('p');
    newParagraph.setAttribute("ios-injected", 1);

    const buttonContainer = document.createElement('div');
    buttonContainer.className = "open_detail_button_container";

    if(linkSpecs.iconSVG) {
        const icon = document.createElement('div');
        icon.className = "open_details_button_icon";
        icon.innerHTML = linkSpecs.iconSVG;
        buttonContainer.appendChild(icon);
    }

    if(linkSpecs.title) {
        const detailButton = document.createElement('a');
        detailButton.className = "open_details_button";
        detailButton.href = buttonHref;
        detailButton.target = "_blank";
        detailButton.textContent = escapeHTML(linkSpecs.title);

        buttonContainer.appendChild(detailButton);
        newParagraph.appendChild(buttonContainer);
    }

    elm.insertAdjacentElement('afterend', newLine);
    newLine.insertAdjacentElement('afterend', newParagraph);
}

function scanMediaFramesInsertingDetailsLinks() {
    document
        .querySelectorAll("iframe[class='lti-embed']")
        .forEach(elm => {
            insertDetailsLinks(elm, "lti");
        });

    document
        .querySelectorAll("iframe[data-media-id]")
        .forEach(elm => {
            insertDetailsLinks(elm, "canvas");
        });
}

function escapeHTML(text) {
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&#039;')
        .replace(/"/g, '&quot;')
}

scanMediaFramesInsertingDetailsLinks();
window.addEventListener("DOMContentLoaded", scanMediaFramesInsertingDetailsLinks);
