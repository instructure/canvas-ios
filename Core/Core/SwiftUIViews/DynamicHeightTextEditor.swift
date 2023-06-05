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
    // MARK: - Dependencies

    @Binding private var text: String
    private let placeholder: String?

    // MARK: - Private properties

    /** The height of the TextEditor. Calculated by  measuring the text's rendered size and adding paddings. */
    @State private var textEditorHeight: CGFloat = 33.5
    // These are estimated values. SwiftUI.TextEditor has some internal paddings which we cannot influence nor measure.
    private let textEditorVerticalPadding: CGFloat = 7
    private let textEditorHorizontalPadding: CGFloat = 5
    private let textEditorTopPadding: CGFloat = 0.5
    @State private var textToMeasureHeight: String = "Placeholder"

    // MARK: - Init

    public init(text: Binding<String>, placeholder: String? = nil) {
        _text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Text(textToMeasureHeight)
                .padding(.vertical, textEditorVerticalPadding)
                .background(GeometryReader {
                    Color.clear.preference(
                        key: ViewSizeKey.self,
                        value: $0.frame(in: .local).size.height
                    )
                }).hidden()
            TextEditor(text: $text)
                .foregroundColor(.textDarkest)
                .background(Color.clear)
                .iOS16HideListScrollContentBackground()
                .frame(height: textEditorHeight)
                .overlay(placeholderView, alignment: .leading)
                .offset(y: -2)
                .onAppear {
                   UITextView.appearance().backgroundColor = .clear
                 }.onDisappear {
                   UITextView.appearance().backgroundColor = nil
                 }
        }
        .onChange(of: text, perform: { newValue in
            textToMeasureHeight = newValue.isEmpty ? "Placeholder" : newValue
        })
        .onPreferenceChange(ViewSizeKey.self) {
            textEditorHeight = $0
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if text.isEmpty, let placeholder = placeholder {
            Text(placeholder)
                .foregroundColor(.textDark)
                .padding(.leading, textEditorHorizontalPadding)
                .padding(.top, textEditorTopPadding)
                .accessibility(hidden: true)
                .allowsHitTesting(false) // Make sure taps go through to the TextEditor, doesn't work on iOS 14
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
