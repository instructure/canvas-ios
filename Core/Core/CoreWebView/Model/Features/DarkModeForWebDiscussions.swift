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

private class DarkModeForWebDiscussions: CoreWebViewFeature {
    private let script: String = {
        let textDark = UIColor.textDark.hexString(userInterfaceStyle: .dark)
        let textDarkest = UIColor.textDark.hexString(userInterfaceStyle: .dark)
        let backgroundLightest = UIColor.backgroundLightest.hexString(userInterfaceStyle: .dark)
        let darkCss = """
        @media (prefers-color-scheme: dark) {
            body {
                background: \(backgroundLightest);
            }
            div[data-testid="discussion-topic-container"] {
                color: \(textDarkest);
            }
            div[data-testid="discussion-root-entry-container"] {
                color: \(textDarkest);
            }

            span[data-testid="mobile-Designer"],
            span[data-testid="mobile-TA"],
            span[data-testid="mobile-Teacher"],
            span[data-testid="mobile-Author"] {
                color: \(textDark);
            }

            /* 3 dots for discussion post actions */
            svg[name="IconMore"] {
                color: \(textDarkest) !important;
            }

            /* Sort and filter bar background */
            .css-sg1rn7-view {
                background-color: \(backgroundLightest) !important;
                color: \(textDark) !important;
            }

            /* No results panda */
            .css-1eo48d6-view-billboard {
                background-color: \(backgroundLightest) !important;
            }
            .css-10v72nd-view-heading {
                color: \(textDarkest) !important;
            }
            .css-x8g1lf-billboard__message {
                color: \(textDark) !important;
            }

            /* Edit post dialog */
            #discussion-details-tab {
                background: \(backgroundLightest);
            }
            #discussion-title {
                background: \(backgroundLightest);
                color: \(textDarkest) !important;
            }
            /* "Post to" header */
            .css-j68kdy-formFieldLabel {
                color: \(textDarkest) !important;
            }
            /* Options header */
            .control-label {
                color: \(textDark) !important;
            }
            /* Checkbox text */
            .control-group {
                color: \(textDarkest);
            }

            /* Available From / Until */
            #delayed_post_at, #lock_at {
                color: \(textDark);
                background: \(backgroundLightest);
            }
        }
        """

        let cssString = darkCss.components(separatedBy: .newlines).joined()
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

    /**
     This feature adds CSS overrides in dark mode for web based discussion pages.
     */
    static var darkModeForWebDiscussions: CoreWebViewFeature {
        DarkModeForWebDiscussions()
    }
}
