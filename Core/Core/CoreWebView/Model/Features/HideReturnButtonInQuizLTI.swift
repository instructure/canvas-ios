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

private class HideReturnButtonInQuizLTI: CoreWebViewFeature {
    private let script: String = {
        let css = """
            a[data-automation="sdk-return-button"] {
                display: none;
            }
        """

        let cssString = css.components(separatedBy: .newlines).joined()
        return """
           var element = document.createElement('style');
           element.innerHTML = '\(cssString)';
           document.head.appendChild(element);
        """
    }()

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

public extension CoreWebViewFeature {

    /// This feature hides the "Return" button in QuizLTI webviews, based on it's `data-automation` id.
    /// The button normally leads the user back to the course home,
    ///  but in the app we can dismiss the screen natively and the "Return" button navigation would cause issues.
    static var hideReturnButtonInQuizLTI: CoreWebViewFeature {
        HideReturnButtonInQuizLTI()
    }
}
