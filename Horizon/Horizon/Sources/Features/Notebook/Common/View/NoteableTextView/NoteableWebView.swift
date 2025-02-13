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

import HorizonUI
import SwiftUI
import Core
import WebKit

/// Part of the Horizon notebook feature, the NoteableTextView encapsulates a block of text
/// That can be highlighted and annotated.
/// It requires a view model for managing logic associated with highlighting and annotation.
struct NoteableWebView: View, HorizonUI.MenuActionsWebView.Delegate {
    let courseId: String?
    let highlightsKey: String
    @Environment(\.viewController) var viewController
    let viewModel: NoteableTextViewModel

    init(
        _ html: String,
        highlightsKey: String,
        courseId: String? = nil,
        typography: HorizonUI.Typography.Name = .p1
    ) {
        self.highlightsKey = highlightsKey
        self.courseId = courseId
        self.viewModel = NoteableTextViewModel.build(
            text: html,
            highlightsKey: highlightsKey,
            typography: typography
        )
    }

    var body: some View {
        HorizonUI.MenuActionsWebView(
            htmlString: viewModel.htmlString,
            delegate: self
        )
    }

    func getMenu(
        webView: WKWebView,
        range: NSRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu {
        viewModel.getMenu(
            highlightsKey: highlightsKey,
            courseId: courseId,
            webView: webView,
            range: range,
            suggestedActions: suggestedActions,
            viewController: viewController
        )
    }

    func onTap(gesture: UITapGestureRecognizer) {
        viewModel.onTap(viewController: viewController, gesture: gesture)
    }
}
