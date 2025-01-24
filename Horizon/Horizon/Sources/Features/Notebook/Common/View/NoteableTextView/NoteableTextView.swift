import HorizonUI
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
import SwiftUI
import Core

/// Part of the Horizon notebook feature, the NoteableTextView encapsulates a block of text
/// That can be highlighted and annotated.
/// It requires a view model for managing  logic associated with highlighting and annotation.
struct NoteableTextView: View, HorizonUI.MenuActionsTextView.Delegate {
    let courseId: String?
    let highlightsKey: String
    @Environment(\.viewController) var viewController
    let viewModel: NoteableTextViewModel

    init(
        _ text: String,
        highlightsKey: String,
        courseId: String? = nil,
        typography: HorizonUI.Typography.Name = .p1
    ) {
        self.highlightsKey = highlightsKey
        self.courseId = courseId
        self.viewModel = NoteableTextViewModel.build(
            text: text,
            highlightsKey: highlightsKey,
            typography: typography
        )
    }

    var body: some View {
        HorizonUI.MenuActionsTextView(
            attributedText: viewModel.attributedText,
            delegate: self
        )
    }

    func getMenu(
        textView: UITextView,
        range: UITextRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu {
        viewModel.getMenu(
            highlightsKey: highlightsKey,
            courseId: courseId,
            textView: textView,
            range: range,
            suggestedActions: suggestedActions,
            viewController: viewController
        )
    }

    func onTap(gesture: UITapGestureRecognizer) {
        viewModel.onTap(viewController: viewController, gesture: gesture)
    }
}

#Preview {
    VStack {
        Text("This text is not selectable. This text is not selectable. This text is not selectable.")
        NoteableTextView(
            "This is some text. You may select some of this text. This is some text. You may select some of this text. This is some text. You may select some of this text.",
            highlightsKey: "Test",
            courseId: "1"
        )
        Text(
            "Again this is not selectable. This is to show that the NoteableTextView expands correctly."
        )
    }
}
