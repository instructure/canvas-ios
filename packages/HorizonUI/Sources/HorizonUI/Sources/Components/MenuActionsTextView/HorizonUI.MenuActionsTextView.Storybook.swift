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

public extension HorizonUI.MenuActionsTextView {
    struct Storybook: View, HorizonUI.MenuActionsTextView.Delegate {
        public func getMenu(textView _: UITextView, range _: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu {
            UIMenu(
                title: "",
                children: [
                    [
                        UIAction(title: "Custom Option #1") { _ in },
                        UIAction(title: "Custom Option #2") { _ in }
                    ],
                    suggestedActions
                ].flatMap { $0 }
            )
        }

        public func onTap(gesture _: UITapGestureRecognizer) {}

        public var body: some View {
            HorizonUI.MenuActionsTextView(
                attributedText: NSAttributedString("This is some text that can be selected. After you select it, you'll see your custom menu options."),
                delegate: self
            )
            .padding(32)
        }
    }
}
