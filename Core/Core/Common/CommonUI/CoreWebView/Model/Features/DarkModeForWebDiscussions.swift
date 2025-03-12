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

import UIKit

private class DarkModeForWebDiscussions: CoreWebViewFeature {
    private let script: String = {
        let textLight = UIColor.textDark.hexString(userInterfaceStyle: .dark)
        let textLightest = UIColor.textDarkest.hexString(userInterfaceStyle: .dark)
        let backgroundDarkest = UIColor.backgroundLightest.hexString(userInterfaceStyle: .dark)
        let darkCss = """
        @media (prefers-color-scheme: dark) {
            body {
                background: \(backgroundDarkest);
            }
            div[data-testid="discussion-topic-container"],
            div[data-testid="discussion-root-entry-container"]{
                color: \(textLightest);
            }

            span[data-testid="mobile-Designer"],
            span[data-testid="mobile-TA"],
            span[data-testid="mobile-Teacher"],
            span[data-testid="mobile-Author"] {
                color: \(textLight);
            }

            /* 3 dots for discussion post actions */
            svg[name="IconMore"] {
                color: \(textLightest) !important;
            }

            /* Sort and filter bar background */
            .css-sg1rn7-view {
                background-color: \(backgroundDarkest) !important;
                color: \(textLight) !important;
            }

            /* No results panda */
            .css-1eo48d6-view-billboard {
                background-color: \(backgroundDarkest) !important;
            }
            .css-10v72nd-view-heading {
                color: \(textLightest) !important;
            }
            .css-x8g1lf-billboard__message {
                color: \(textLight) !important;
            }

            button[data-testid="groups-menu-btn"] span,
            button[data-testid="sortButton"] span,
            button[data-testid="ExpandCollapseThreads-button"] span,
            button[data-testid="splitscreenButton"] span {
                color: \(textLightest);
                background: \(backgroundDarkest);
                border-top-color: \(textLight);
                border-right-color: \(textLight);
                border-bottom-color: \(textLight);
                border-left-color: \(textLight);
            }

            /* View dropdown */
            ul[role="listbox"] li span {
                color: \(textLightest);
                background: \(backgroundDarkest);
            }
            .css-1dn3ise-textInput__facade {
                background: \(backgroundDarkest) !important;
            }

            /* Selected List Item */
            span[aria-selected="true"] {
                color: \(backgroundDarkest) !important;
                background: \(textLight) !important;
            }
            input[role="combobox"] {
                color: \(textLightest) !important;
                background: \(backgroundDarkest) !important;
            }

            /* Kebab menu */
            ul[role="menu"] li span {
                color: \(textLightest);
                background-color: \(backgroundDarkest);
            }
            ul[role="menu"] {
                background: \(backgroundDarkest);
            }

            /* Info boxes */
            span[data-testid="anon-conversation"],
            span[data-testid="locked-for-user"],
            span[data-testid="post-required"] {
                color: \(textLightest) !important;
            }
            .css-1oqo41g-view-alert {
                background: \(backgroundDarkest) !important;
            }

            svg[name="IconBookmark"] {
                color: \(textLight) !important;
            }

            /* Search bar */
            .css-1jienkz-textInput__facade,
            .css-z3sx20-textInput__facade,
            .css-7naoe-textInput__facade,
            .css-1dn3ise-textInput__facade,
            button[data-testid="manage-assign-to"] span {
                color: \(textLightest) !important;
                background: \(backgroundDarkest) !important;
            }
            input[data-testid="search-filter"]::placeholder,
            input[data-testid="search-filter"],
            input[data-testid="search-filter"]:focus,
            button[data-testid="clear-search-button"] span {
                color: \(textLightest) !important;
            }

            /********************/
            /* Edit post dialog */
            /********************/

            #discussion-details-tab {
                background: \(backgroundDarkest);
            }
            #discussion-title {
                background: \(backgroundDarkest);
                color: \(textLightest) !important;
            }
            /* "Post to" header */
            .css-j68kdy-formFieldLabel {
                color: \(textLightest) !important;
            }
            /* Options header */
            .control-label {
                color: \(textLight) !important;
            }
            /* Checkbox text */
            .control-group {
                color: \(textLightest);
            }

            /* Available From / Until */
            #delayed_post_at, #lock_at {
                color: \(textLight);
                background: \(backgroundDarkest);
            }

            /* Options Section Header */
            .css-mum2ig-text {
                color: \(textLightest);
            }
            /* Participants must respond... label */
            .css-1ek001j-checkboxFacade__label {
                color: \(textLightest) !important;
            }

            /* Allow liking label */
            .css-1ek001j-checkboxFacade__label {
                color: \(textLightest) !important;
            }

            /* Group settings cannot be changed warning box. */
            span[data-testid="group-category-not-editable"] div {
                color: \(textLightest);
            }
            .css-qfe6jw {
                background: \(backgroundDarkest);
            }

            #TextInput_1 {
                color: \(textLightest);
            }

            /* Anonym discussion radio buttons*/
            .css-dx107t-radioInput__label {
                color: \(textLightest) !important;
            }

            /* Assign to */
            span[data-testid="module-item-edit-tray"],
            span[data-testid="module-item-edit-tray-footer"] div {
                background: \(backgroundDarkest);
            }

            /* Assign to header */
            .css-1p1yt21-view-flexItem,
            .css-12w1q2i-baseButton__content {
                color: \(textLightest) !important;
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
