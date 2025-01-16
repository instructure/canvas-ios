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

import SwiftUI
import UIKit

extension HorizonUI {
    public struct MenuActionsTextView: UIViewRepresentable {
        private let attributedText: NSAttributedString
        private let delegate: HorizonUI.MenuActionsTextView.Delegate

        public init(
            attributedText: NSAttributedString,
            delegate: Delegate
        ) {
            self.attributedText = attributedText
            self.delegate = delegate
        }

        public func makeUIView(context: Context) -> UITextView {
            MenuActionsUITextView(delegate: delegate)
        }

        public func updateUIView(_ uiView: UITextView, context: Context) {
            uiView.attributedText = attributedText
            uiView.sizeToFit()
        }
    }
}

extension HorizonUI.MenuActionsTextView {
    public protocol Delegate {
        func getMenu(
            textView: UITextView,
            range: UITextRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu

        func onTap(gesture: UITapGestureRecognizer)
    }
}

private class MenuActionsUITextView: UITextView {

    private let menuActionsUITextViewDelegate: HorizonUI.MenuActionsTextView.Delegate?

    init(delegate: HorizonUI.MenuActionsTextView.Delegate) {
        self.menuActionsUITextViewDelegate = delegate

        super.init(frame: .zero, textContainer: nil)

        self.isEditable = false
        self.isSelectable = true
        self.attributedText = NSAttributedString(string: text)
        self.backgroundColor = .clear
        self.isScrollEnabled = false
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.textContainer.maximumNumberOfLines = 0
        self.textContainer.lineBreakMode = .byWordWrapping
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
        self.sizeToFit()
    }

    required init?(coder: NSCoder) {
        self.menuActionsUITextViewDelegate = nil
        super.init(coder: coder)
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        menuActionsUITextViewDelegate?.onTap(gesture: gesture)
    }

    override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        menuActionsUITextViewDelegate?.getMenu(textView: self, range: textRange, suggestedActions: suggestedActions)
    }
}
