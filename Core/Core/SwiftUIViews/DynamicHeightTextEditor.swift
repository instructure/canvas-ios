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
@available(iOS 14, *)
public struct DynamicHeightTextEditor: View {
    @Binding private var text: String
    /** The height of the TextEditor. Calculated by manually measuring the text's rendered size and adding paddings.*/
    @State private var height: CGFloat
    /** The measured available width. The initial value is just a placeholder until the view is actually rendered. */
    @State private var width: CGFloat = 300
    private let maxHeight: CGFloat
    private let minHeight: CGFloat
    private let placeholder: String?
    /** This is required to measure the text's height with `NSString`'s `boundingRect` method. We can't use `Font` or get it from `Environment` because `SwiftUI.Font` cannot be converted into `UIFont.` */
    private let font: UIFont
    // These are estimated values. SwiftUI.TextEditor has some internal paddings which we cannot influence nor measure.
    private let textEditorVerticalPadding: CGFloat = 7
    private let textEditorHorizontalPadding: CGFloat = 5

    public init(text: Binding<String>, maxLines: Int, font: UIFont, placeholder: String? = nil) {
        let minHeight = font.lineHeight + 2 * textEditorVerticalPadding
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = CGFloat(maxLines) * font.lineHeight + 2 * textEditorVerticalPadding
        self.placeholder = placeholder
        self.font = font
        self.height = minHeight
        updateHeight()
    }

    public var body: some View {
        GeometryReader { geometry in // Just to measure the available width
            TextEditor(text: $text)
                .font(Font(font))
                .foregroundColor(.textDarkest)
                .frame(height: height)
                .preference(key: ViewSizeKey.self, value: CGSize(width: geometry.size.width - 2 * textEditorHorizontalPadding, height: 0))
                .overlay(placeholderView, alignment: .topLeading)
        }
        .frame(maxHeight: height) // height must be limited to the text height, otherwise the geometry reader fills all available space vertically
        .onChange(of: text) { _ in updateHeight() }
        .onAppear(perform: updateHeight)
        .onPreferenceChange(ViewSizeKey.self, perform: { size in
            self.width = size.width
            updateHeight()
        })
    }

    @ViewBuilder
    private var placeholderView: some View {
        if text.isEmpty, let placeholder = placeholder, #available(iOS 15, *) {
            Text(placeholder)
                .font(Font(font))
                .foregroundColor(.textDark)
                .padding(.top, textEditorVerticalPadding)
                .padding(.leading, textEditorHorizontalPadding)
                .accessibility(hidden: true)
                .allowsHitTesting(false) // Make sure taps go through to the TextEditor, doesn't work on iOS 14
        }
    }

    /**
     This method renders the text offscreen to measure its height for the current width. This measured height will be the height of the TextEditor.
     */
    private func updateHeight() {
        let sizeConstraint = CGSize(width: width, height: .greatestFiniteMagnitude)
        var measuredTextHeight = NSString(string: text).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
        measuredTextHeight += 2 * textEditorVerticalPadding
        height = min(maxHeight, max(minHeight, measuredTextHeight))
    }
}

#if DEBUG

@available(iOSApplicationExtension 14, *)
struct DynamicHeightTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        DynamicHeightTextEditor(text: .constant(""), maxLines: 3, font: .scaledNamedFont(.regular14), placeholder: "Placeholder")
        .previewLayout(.sizeThatFits)
        .border(Color.red)

        DynamicHeightTextEditor(text: .constant("Placeholder"), maxLines: 3, font: .scaledNamedFont(.regular14), placeholder: "Placeholder")
        .previewLayout(.sizeThatFits)
        .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1"), maxLines: 3, font: .scaledNamedFont(.regular14))
        .previewLayout(.sizeThatFits)
        .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2"), maxLines: 3, font: .scaledNamedFont(.regular14))
        .previewLayout(.sizeThatFits)
        .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2\n3"), maxLines: 3, font: .scaledNamedFont(.regular14))
        .previewLayout(.sizeThatFits)
        .border(Color.red)

        DynamicHeightTextEditor(text: .constant("1\n2\n3\n4\n5\n6\n7\n8\n9"), maxLines: 3, font: .scaledNamedFont(.regular14))
        .previewLayout(.sizeThatFits)
        .border(Color.red)
    }
}

#endif
