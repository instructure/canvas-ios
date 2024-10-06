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

public struct SelectableText: UIViewRepresentable {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let text: String?
    private let attributedText: AttributedString?
    private let font: UIFont.Name
    private let textColor: Color

    // MARK: - Inits
    public init(
        text: String,
        font: UIFont.Name,
        textColor: Color
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.attributedText = nil
    }

    public init(
        attributedText: AttributedString,
        font: UIFont.Name,
        textColor: Color
    ) {
        self.attributedText = attributedText
        self.font = font
        self.textColor = textColor
        self.text = nil
    }

    public func makeUIView(context: Self.Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.scaledNamedFont(font)
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.textContainerInset = .zero
        textView.isEditable = false
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Self.Context) {
        if let attributedText {
            textView.attributedText = NSAttributedString(attributedText)
        } else {
            textView.text = text
        }
        textView.textColor = UIColor(textColor)
        textView.font = UIFont.scaledNamedFont(font)
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UITextView,
        context: Self.Context
    ) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: .init(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )

        let calculatedHeight = calculateTextViewHeight(
            containerSize: dimensions,
            attributedString: uiView.attributedText
        )

        return .init(
            width: dimensions.width,
            height: calculatedHeight
        )
    }

    private func calculateTextViewHeight(
        containerSize: CGSize,
        attributedString: NSAttributedString
    ) -> CGFloat {
        let boundingRect = attributedString.boundingRect(
            with: .init(width: containerSize.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return boundingRect.height
    }
}
