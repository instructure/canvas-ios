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

private class DisableLinksOverlayPreviews: CoreWebViewFeature {

    private let script: String = {
        return """
        function disableLinksOverlayPreviews() {
            const spans = document.querySelectorAll('span.instructure_file_link_holder');

            spans.forEach(elm => {
                const a1 = elm.querySelector("a.preview_in_overlay");
                const a2 = elm.querySelector("a.file_download_btn");

                if(a1 && a2) {
                    const d_href1 = a1.getAttributeNode("href");
                    const d_href2 = a2.getAttributeNode("href");
                    d_href1.value = d_href2.value;

                    const d_class1 = a1.getAttributeNode("class");
                    d_class1.value = d_class1.value.replace("preview_in_overlay", "no_preview");
                }
            })
        }
        window.addEventListener("DOMSubtreeModified", disableLinksOverlayPreviews)
        """
    }()

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {

    /**
     This feature is to disable preview on all links of the loaded page.
     */
    static var disableLinksOverlayPreviews: CoreWebViewFeature {
        DisableLinksOverlayPreviews()
    }
}
