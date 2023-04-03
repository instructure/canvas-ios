//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

/**
 When opening a classic quiz preview url a quiz properties page is displayed before the actual quiz preview.
 This script taps on the button that hides the properties screen and shows the quiz.
 */
public class SkipQuizPreviewSummary: CoreWebViewFeature {
    private let script: String =
    """
        var previewButton = document.getElementById('preview_quiz_button');
        if (previewButton) {
            previewButton.click();
        }
    """

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {

    /**
     When opening a classic quiz preview url a quiz properties page is displayed before the actual quiz preview.
     This script taps on the button that hides the properties screen and shows the quiz.
     */
    static var skipQuizPreviewSummary: SkipQuizPreviewSummary {
        SkipQuizPreviewSummary()
    }
}
