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

import Core
import WebKit

class HighlightWebFeature: CoreWebViewFeature {

    override init() {
    }

    override func apply(on configuration: WKWebViewConfiguration) {
        super.apply(on: configuration)
        // Create a WKUserContentController to handle the user scripts
        let userContentController = WKUserContentController()

        // Create a WKUserScript with your custom JavaScript file
        if let jsFilePath = Bundle(identifier: "com.instructure.horizon")?.path(forResource: "WebHighlighting", ofType: "js"),
           let jsString = try? String(contentsOfFile: jsFilePath, encoding: .utf8) {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(userScript)
        }

        configuration.userContentController = userContentController
    }
}
