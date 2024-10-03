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

public struct SelectableTextViewWrapper: UIViewRepresentable {
    // MARK: - Properties
    private let textType: TextType
    private let font: UIFont.Name
    private let textColor: Color

    // MARK: - Init
    public init(
        textType: TextType,
        font: UIFont.Name,
        textColor: Color
    ) {
        self.textType = textType
        self.font = font
        self.textColor = textColor
    }

    public func makeUIView(context: Self.Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.scaledNamedFont(font)
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.textContainerInset = .zero
        textView.isEditable = false
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Self.Context) {
        switch textType {
        case .text(let value):
            textView.text = value
        case .attributedText(let value):
            textView.attributedText = NSAttributedString(value)
        }
        textView.textColor = UIColor(textColor)
        textView.font = UIFont.scaledNamedFont(font)
    }
}

extension SelectableTextViewWrapper {
  public enum TextType {
        case text(value: String)
        case attributedText(value: AttributedString)
    }
}
