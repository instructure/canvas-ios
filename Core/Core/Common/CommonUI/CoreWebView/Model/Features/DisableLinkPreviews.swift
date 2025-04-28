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

private class DisableLinkPreviews: CoreWebViewFeature {

    private let script: String = {
        return """
        function disableLinksPreviews() {
            const links = document.querySelectorAll('a.inline_disabled.preview_in_overlay')
            links.forEach(elm => {
                const d_rel = elm.getAttributeNode("class");
                d_rel.value = "inline_disabled no_preview"
            })
        }
        window.addEventListener("DOMSubtreeModified", disableLinksPreviews)
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
    static var disableLinkPreviews: CoreWebViewFeature {
        DisableLinkPreviews()
    }
}
