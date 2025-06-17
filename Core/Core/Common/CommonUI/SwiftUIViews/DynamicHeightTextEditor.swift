//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

/**
 This text editor starts as a one line height component, then as text is entered it grows until its maximum height is reached.
 */
public struct DynamicHeightTextEditor: View {

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @Binding private var text: String
    private let placeholder: String?
    private let font: UIFont.Name
    private let lineHeight: Typography.LineHeight
    private let lineLimit: CGFloat?
    private let isScrollDisabled: Bool

    @State private var textViewHeight: CGFloat = 0

    // MARK: - Init

    public init(
        text: Binding<String>,
        placeholder: String? = nil,
        font: UIFont.Name,
        lineHeight: Typography.LineHeight = .fit,
        lineLimit: CGFloat? = nil,
        isScrollDisabled: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        self.font = font
        self.lineHeight = lineHeight
        self.lineLimit = lineLimit
        self.isScrollDisabled = isScrollDisabled
    }

    public var body: some View {
        UITextViewWrapper(text: $text, height: $textViewHeight) { textView in
            textView.isScrollEnabled = !isScrollDisabled
            textView.backgroundColor = .clear
            textView.textColor = .textDarkest
            textView.font(.scaledNamedFont(font), lineHeight: lineHeight)
        }
        .scrollContentBackground(.hidden)
        .frame(maxHeight: height, alignment: .topLeading)
        .overlay(placeholderView, alignment: .topLeading)
    }

    private var height: CGFloat {
        guard let lineLimit else { return textViewHeight }

        let modifiedLineHeight = lineHeight.toPoints(for: .scaledNamedFont(font))
        return min(textViewHeight, lineLimit * modifiedLineHeight)
    }

    @ViewBuilder
    private var placeholderView: some View {
        if let placeholder, text.isEmpty {
            Text(placeholder)
                .foregroundStyle(.textPlaceholder)
                .font(font, lineHeight: lineHeight)
                .allowsHitTesting(false)
                .accessibility(hidden: true)
        }
    }
}

#if DEBUG

//struct DynamicHeightTextEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        DynamicHeightTextEditor(text: .constant(""), placeholder: "Placeholder")
//            .font(.regular14)
//            .previewLayout(.sizeThatFits)
//            .border(Color.red)
//
//        DynamicHeightTextEditor(text: .constant("Placeholder"), placeholder: "Placeholder")
//            .font(.regular14)
//            .previewLayout(.sizeThatFits)
//            .border(Color.red)
//
//        DynamicHeightTextEditor(text: .constant("1"))
//            .font(.regular14)
//            .previewLayout(.sizeThatFits)
//            .border(Color.red)
//
//        DynamicHeightTextEditor(text: .constant("1\n2"))
//            .previewLayout(.sizeThatFits)
//            .font(.regular14)
//            .border(Color.red)
//
//        DynamicHeightTextEditor(text: .constant("1\n2\n3"))
//            .font(.regular14)
//            .lineLimit(2)
//            .previewLayout(.sizeThatFits)
//            .border(Color.red)
//
//        DynamicHeightTextEditor(text: .constant("1\n2\n3\n4\n5\n6\n7\n8\n9"))
//            .font(.regular14)
//            .lineLimit(3)
//            .previewLayout(.sizeThatFits)
//            .border(Color.red)
//    }
//}

#endif
