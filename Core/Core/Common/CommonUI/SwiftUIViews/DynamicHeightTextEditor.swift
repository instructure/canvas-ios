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
    static let negatedVerticalPaddings = InstUI.Styles.Padding.textEditorVerticalCorrection.rawValue * -2

    // MARK: - Dependencies

    @Binding private var text: String
    private let placeholder: String?

    // MARK: - Private properties

    /** The height of the TextEditor. Calculated by  measuring the text's rendered size and adding paddings. */
    @State private var textEditorHeight: CGFloat = 0

    // MARK: - Init

    public init(text: Binding<String>, placeholder: String? = nil) {
        _text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text.nilIfEmpty ?? placeholder ?? "Placeholder")
                .onSizeChange {
                    textEditorHeight = $0.height + Self.negatedVerticalPaddings
                }
                .allowsHitTesting(false)
                .hidden()

            TextEditor(text: $text)
                .foregroundColor(.textDarkest)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .frame(height: textEditorHeight)
                .paddingStyle(set: .textEditorCorrection)
                .overlay(placeholderView, alignment: .topLeading)
        }
        .clipped()
    }

    @ViewBuilder
    private var placeholderView: some View {
        if let placeholder, text.isEmpty {
            Text(placeholder)
                .foregroundStyle(.textPlaceholder)
                .offset(y: 1.5)
                .allowsHitTesting(false)
                .accessibility(hidden: true)
        }
    }
}

#if DEBUG

struct DynamicHeightTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        DynamicHeightTextEditor(text: .constant(""), placeholder: "Placeholder")
            .font(.regular14)
            .previewLayout(.sizeThatFits)
            .border(Color.red)

        DynamicHeightTextEditor(text: .constant("Placeholder"), placeholder: "Placeholder")
            .font(.regular14)
            .previewLayout(.sizeThatFits)
            .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1"))
            .font(.regular14)
            .previewLayout(.sizeThatFits)
            .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2"))
            .previewLayout(.sizeThatFits)
            .font(.regular14)
            .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2\n3"))
            .font(.regular14)
            .lineLimit(2)
            .previewLayout(.sizeThatFits)
            .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2\n3\n4\n5\n6\n7\n8\n9"))
            .font(.regular14)
            .lineLimit(3)
            .previewLayout(.sizeThatFits)
            .border(Color.red)
    }
}

#endif
