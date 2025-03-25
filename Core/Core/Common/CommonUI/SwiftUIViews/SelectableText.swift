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

public struct SelectableText: View {

    private let attributedText: AttributedString
    private let font: UIFont.Name
    private let lineHeight: Typography.LineHeight?
    private let textColor: Color

    public init(
        text: String,
        font: UIFont.Name,
        lineHeight: Typography.LineHeight? = nil,
        textColor: Color
    ) {
        self.attributedText = AttributedString(text)
        self.font = font
        self.lineHeight = lineHeight
        self.textColor = textColor
    }

    public init(
        attributedText: AttributedString,
        font: UIFont.Name,
        lineHeight: Typography.LineHeight? = nil,
        textColor: Color
    ) {
        self.attributedText = attributedText
        self.font = font
        self.lineHeight = lineHeight
        self.textColor = textColor
    }

    public var body: some View {
        WrappedSelectableTextView(
            attributedText: attributedText,
            font: font,
            lineHeight: lineHeight,
            textColor: textColor
        )
        .padding(.vertical, 1)
    }
}

private struct WrappedSelectableTextView: UIViewRepresentable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Properties

    private let attributedText: AttributedString
    private let font: UIFont.Name
    private let lineHeight: Typography.LineHeight?
    private let textColor: Color

    // MARK: - Init

    init(
        attributedText: AttributedString,
        font: UIFont.Name,
        lineHeight: Typography.LineHeight? = nil,
        textColor: Color
    ) {
        self.attributedText = attributedText
        self.font = font
        self.lineHeight = lineHeight
        self.textColor = textColor
    }

    // MARK: - UIViewRepresentable methods

    func makeUIView(context: Self.Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Self.Context) {
        let uiFont = UIFont.scaledNamedFont(font)
        var attributedText = attributedText
        attributedText.font = uiFont

        if let lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight.lineSpacing(for: uiFont)

            attributedText.mergeAttributes(.init([.paragraphStyle: paragraphStyle]))
        }

        textView.attributedText = NSAttributedString(attributedText)
        textView.textColor = UIColor(textColor)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UITextView,
        context: Self.Context
    ) -> CGSize? {
        let proposedWidth = proposal.width ?? 0
        let calculatedHeight = calculateTextViewHeight(with: proposedWidth, for: uiView.attributedText)

        return CGSize(width: proposedWidth, height: calculatedHeight)
    }

    private func calculateTextViewHeight(
        with width: CGFloat,
        for attributedString: NSAttributedString
    ) -> CGFloat {
        let boundingRect = attributedString.boundingRect(
            with: .init(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        // the calculated height must be ceiled, according to the `boundingRect` documentation
        return ceil(boundingRect.height)
    }
}
