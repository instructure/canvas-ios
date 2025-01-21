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

    /// Wraps the custom UITextView in UIViewRepresentable to make it available for SwiftUI
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

/// Methods that our custom UITextView depends on having implemented
extension HorizonUI.MenuActionsTextView {
    @MainActor
    public protocol Delegate {
        /// Gets the buttons to be displayed to the user when a body of text is selected
        func getMenu(
            textView: UITextView,
            range: UITextRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu

        /// Called when the user taps on the text view
        func onTap(gesture: UITapGestureRecognizer)
    }
}

/// A custom UITextView for adding the custom buttons when highlighting text
private class MenuActionsUITextView: UITextView {

    private let menuActionsUITextViewDelegate: HorizonUI.MenuActionsTextView.Delegate?

    init(delegate: HorizonUI.MenuActionsTextView.Delegate) {
        self.menuActionsUITextViewDelegate = delegate

        super.init(frame: .zero, textContainer: nil)

        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.contentInset = .zero
        self.textContainer.lineFragmentPadding = 0
        self.backgroundColor = .clear

        self.isEditable = false
        self.isSelectable = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))

        DispatchQueue.main.async {
            //on the first pass, the contentSize is incorrect
            //we invalidate the intrinsic content size to cause a recalculation
            self.invalidateIntrinsicContentSize()
        }
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

    override var intrinsicContentSize: CGSize {
        return frame.height > 0 ? contentSize : super.intrinsicContentSize
    }
}
