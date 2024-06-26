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

extension InstUI {

    public struct TextFieldCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Text?
        private let labelTransform: (Text) -> Label
        private let customAccessibilityLabel: Text?
        private let placeholder: String

        @Binding private var text: String
        @FocusState private var isFocused: Bool

        private var accessibilityLabel: Text {
            customAccessibilityLabel ?? label ?? Text("")
        }

        private var accessibilityValue: String {
            // adding pause before `value`, not after `label`, otherwise it will be read out
            let pause = accessibilityLabel != Text("") ? "," : ""
            let value = text.nilIfEmpty ?? placeholder
            return pause + value
        }

        public init(
            label: Text?,
            labelTransform: @escaping (Text) -> Label = { $0 },
            customAccessibilityLabel: Text? = nil,
            placeholder: String,
            text: Binding<String>
        ) {
            self.label = label
            self.labelTransform = labelTransform
            self.customAccessibilityLabel = customAccessibilityLabel
            self.placeholder = placeholder
            self._text = text
        }

        public init(
            customAccessibilityLabel: Text? = nil,
            placeholder: String,
            text: Binding<String>
        ) where Label == Text? {
            self.init(
                label: nil,
                labelTransform: { $0 },
                customAccessibilityLabel: customAccessibilityLabel,
                placeholder: placeholder,
                text: text
            )
        }

        public var body: some View {
            VStack(spacing: 0) {
                SwiftUI.Group {
                    if let label {
                        HStack(alignment: .top, spacing: 0) {
                            labelTransform(label)
                                .textStyle(.cellLabel)
                                .paddingStyle(.trailing, .standard)
                                .accessibility(hidden: true)

                            textField
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        textField
                    }
                }
                .paddingStyle(set: .standardCell)

                InstUI.Divider()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
        }

        private var textField: some View {
            if #available(iOS 16, *) {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.placeholderGray), axis: .vertical)
                    .focused($isFocused)
                    .multilineTextAlignment(.leading)
                    .font(label == nil ? .semibold16 : .regular16, lineHeight: .fit)
                    .foregroundStyle(Color.textDarkest)
                    .submitLabel(.done)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityValue(accessibilityValue)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.placeholderGray))
                    .focused($isFocused)
                    .multilineTextAlignment(.leading)
                    .font(label == nil ? .semibold16 : .regular16, lineHeight: .fit)
                    .foregroundStyle(Color.textDarkest)
                    .submitLabel(.done)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityValue(accessibilityValue)
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.Divider()
        InstUI.TextFieldCell(placeholder: "Add text here", text: .constant(""))
        InstUI.TextFieldCell(label: Text(verbatim: "Label"), placeholder: "Add text here", text: .constant(""))
        InstUI.TextFieldCell(label: Text(verbatim: "Label"), placeholder: "Add text here", text: .constant(InstUI.PreviewData.loremIpsumMedium))
        InstUI.TextFieldCell(
            label: Text(verbatim: "Styled Label"),
            labelTransform: {
                $0
                    .foregroundStyle(Color.red)
                    .textStyle(.heading)
            },
            placeholder: "Add text here",
            text: .constant("Some text entered")
        )
    }
}

#endif
