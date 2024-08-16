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

    public struct TextEditorCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Text?
        private let labelTransform: (Text) -> Label
        private let customAccessibilityLabel: Text?
        private let placeholder: String?

        @Binding private var text: String
        @FocusState private var isFocused: Bool
        @State private var textHeight: CGFloat = 1

        private var accessibilityLabel: Text {
            let label = customAccessibilityLabel ?? label ?? Text("")
            // `pause` is not needed here
            let placeholder = Text(text.isEmpty ? placeholder ?? "" : "")
            return label + placeholder
        }

        public init(
            label: Text?,
            labelTransform: @escaping (Text) -> Label = { $0 },
            customAccessibilityLabel: Text? = nil,
            placeholder: String? = nil,
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
            placeholder: String? = nil,
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
            SwiftUI.Group {
                if let label {
                    VStack(spacing: 0) {
                        labelTransform(label)
                            .textStyle(.cellLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(.bottom, .cellBottom)
                            .accessibility(hidden: true)

                        textEditor
                    }
                } else {
                    textEditor
                }
            }
            .paddingStyle(set: .standardCell)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
        }

        private var textEditor: some View {
            ZStack(alignment: .topLeading) {
                Text(text.nilIfEmpty ?? placeholder ?? "Placeholder")
                    .background(GeometryReader {
                        Color.clear.preference(
                            key: ViewSizeKey.self,
                            value: $0.size.height
                        )
                    })
                    .hidden()
                TextEditor(text: $text)
                    .paddingStyle(set: .textEditorCorrection)
                    .scrollDisabled(true)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .overlay(placeholderView, alignment: .leading)
                    .foregroundStyle(Color.textDarkest)
                    .frame(height: textHeight)
                    .accessibilityLabel(accessibilityLabel)
            }
            .font(.regular16, lineHeight: .fit)
            .onPreferenceChange(ViewSizeKey.self) { value in
                textHeight = value + 4 // adding height buffer to mitigate jumping to top as text grows
            }
        }

        @ViewBuilder
        private var placeholderView: some View {
            if let placeholder, text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.placeholderGray)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                    .accessibility(hidden: true)
            }
        }
    }
}

#if DEBUG

#Preview {
    InstUI.BaseScreen(state: .data, config: .init(refreshable: false)) { _ in
        VStack(spacing: 0) {
            InstUI.Divider()
            InstUI.TextEditorCell(
                placeholder: "Add text here",
                text: .constant("")
            )
            InstUI.Divider()
            InstUI.TextEditorCell(
                placeholder: "Add text here",
                text: .constant(InstUI.PreviewData.loremIpsumLong)
            )
            InstUI.Divider()
            InstUI.TextEditorCell(
                label: Text(verbatim: "Label"),
                placeholder: "Add text here",
                text: .constant(InstUI.PreviewData.loremIpsumLong(2))
            )
            InstUI.Divider()
            InstUI.TextEditorCell(
                label: Text(verbatim: "Styled Label"),
                labelTransform: {
                    $0
                        .foregroundStyle(Color.red)
                        .textStyle(.heading)
                },
                text: .constant(InstUI.PreviewData.loremIpsumLong(2))
            )
            InstUI.Divider()
            InstUI.TextEditorCell(
                text: .constant("")
            )
            InstUI.Divider()
            InstUI.TextEditorCell(
                text: .constant(InstUI.PreviewData.loremIpsumLong(2))
            )
        }
    }
}

#endif
