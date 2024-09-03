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
import Combine

extension InstUI {

    public struct RichContentEditorCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Text?
        private let labelTransform: (Text) -> Label
        private let customAccessibilityLabel: Text?
        private let placeholder: String

        @Binding private var text: String
        @Binding private var isUploading: Bool
        @Binding private var error: Error?
        @State private var rceHeight: CGFloat = 0

        @FocusState private var isFocused: Bool
        private let onFocus: (() -> Void)?
        private let focusedPublisher = PassthroughSubject<Void, Never>()

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
            placeholder: String? = nil,
            text: Binding<String>,
            isUploading: Binding<Bool> = .constant(false),
            error: Binding<Error?> = .constant(nil),
            onFocus: (() -> Void)? = nil
        ) {
            self.label = label
            self.labelTransform = labelTransform
            self.customAccessibilityLabel = customAccessibilityLabel
            self.placeholder = placeholder ?? ""
            self._text = text
            self._isUploading = isUploading
            self._error = error
            self.onFocus = onFocus
        }

        public init(
            customAccessibilityLabel: Text? = nil,
            placeholder: String? = nil,
            text: Binding<String>,
            isUploading: Binding<Bool> = .constant(false),
            error: Binding<Error?> = .constant(nil),
            onFocus: (() -> Void)? = nil
        ) where Label == Text? {
            self.init(
                label: nil,
                labelTransform: { $0 },
                customAccessibilityLabel: customAccessibilityLabel,
                placeholder: placeholder,
                text: text,
                isUploading: isUploading,
                error: error,
                onFocus: onFocus
            )
        }

        public var body: some View {
            SwiftUI.Group {
                if let label {
                    VStack(spacing: 0) {
                        labelTransform(label)
                            .textStyle(.cellLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(.top, .cellTop)
                            .paddingStyle(.horizontal, .standard)
                            .accessibility(hidden: true)

                        rcEditor
                    }
                } else {
                    rcEditor
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .onChange(of: isFocused) {
                guard $0 else { return }
                focusedPublisher.send()
            }
        }

        private var rcEditor: some View {
            return RichContentEditor(
                placeholder: placeholder,
                a11yLabel: "Some custom acc label",
                html: $text,
                context: .currentUser, // TODO: inject
                uploadTo: .context(.currentUser), // TODO: file context, inject or calculate
                height: $rceHeight,
                isUploading: $isUploading,
                error: $error,
                onFocus: onFocus,
                focusTrigger: focusedPublisher.eraseToAnyPublisher()
            )
            .scrollDisabled(true)
            .focused($isFocused)
            .frame(height: rceHeight)
//            .accessibilityLabel(accessibilityLabel)
//            .accessibilityValue(accessibilityValue)
        }
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.RichContentEditorCell(placeholder: "Add text here", text: .constant(""))
        InstUI.RichContentEditorCell(label: Text(verbatim: "Label"), placeholder: "Add text here", text: .constant(""))
        InstUI.RichContentEditorCell(label: Text(verbatim: "Label"), placeholder: "Add text here", text: .constant(InstUI.PreviewData.loremIpsumMedium))
        InstUI.RichContentEditorCell(
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
