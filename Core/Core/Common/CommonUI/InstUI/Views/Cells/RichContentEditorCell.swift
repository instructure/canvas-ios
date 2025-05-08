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
        @Environment(\.appEnvironment) private var env

        private let label: Text?
        private let labelTransform: (Text) -> Label
        private let customAccessibilityLabel: Text?
        private let placeholder: String
        private let uploadParameters: RichContentEditorUploadParameters

        @Binding private var html: String
        @Binding private var isUploading: Bool
        @Binding private var error: Error?
        @State private var rceHeight: CGFloat = 0

        @FocusState private var isFocused: Bool
        private let onFocus: (() -> Void)?
        private let focusedPublisher = PassthroughSubject<Void, Never>()

        private var accessibilityLabel: Text {
            customAccessibilityLabel ?? label ?? Text("")
        }

        public init(
            label: Text?,
            labelTransform: @escaping (Text) -> Label = { $0 },
            customAccessibilityLabel: Text? = nil,
            placeholder: String? = nil,
            html: Binding<String>,
            uploadParameters: RichContentEditorUploadParameters,
            isUploading: Binding<Bool> = .constant(false),
            error: Binding<Error?> = .constant(nil),
            onFocus: (() -> Void)? = nil
        ) {
            self.label = label
            self.labelTransform = labelTransform
            self.customAccessibilityLabel = customAccessibilityLabel
            self.placeholder = placeholder ?? ""
            self._html = html
            self.uploadParameters = uploadParameters
            self._isUploading = isUploading
            self._error = error
            self.onFocus = onFocus
        }

        public init(
            customAccessibilityLabel: Text? = nil,
            placeholder: String? = nil,
            html: Binding<String>,
            uploadParameters: RichContentEditorUploadParameters,
            isUploading: Binding<Bool> = .constant(false),
            error: Binding<Error?> = .constant(nil),
            onFocus: (() -> Void)? = nil
        ) where Label == Text? {
            self.init(
                label: nil,
                labelTransform: { $0 },
                customAccessibilityLabel: customAccessibilityLabel,
                placeholder: placeholder,
                html: html,
                uploadParameters: uploadParameters,
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
                guard isFocused else { return }
                focusedPublisher.send()
            }
        }

        private var rcEditor: some View {
            return RichContentEditor(
                env: env,
                placeholder: placeholder,
                a11yLabel: "",
                html: $html,
                uploadParameters: uploadParameters,
                height: $rceHeight,
                isUploading: $isUploading,
                error: $error,
                onFocus: onFocus,
                focusTrigger: focusedPublisher.eraseToAnyPublisher()
            )
            .scrollDisabled(true)
            .focused($isFocused)
            .frame(height: rceHeight)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityLabel)
        }
    }
}

#if DEBUG

#Preview {
    let uploadParameters = RichContentEditorUploadParameters(context: .course("1"))

    return VStack {
        InstUI.RichContentEditorCell(placeholder: "Add text here", html: .constant(""), uploadParameters: uploadParameters)
        InstUI.RichContentEditorCell(label: Text(verbatim: "Label"), placeholder: "Add text here", html: .constant(""), uploadParameters: uploadParameters)
        InstUI.RichContentEditorCell(label: Text(verbatim: "Label"), placeholder: "Add text here", html: .constant(InstUI.PreviewData.loremIpsumMedium), uploadParameters: uploadParameters)
        InstUI.RichContentEditorCell(
            label: Text(verbatim: "Styled Label"),
            labelTransform: {
                $0
                    .foregroundStyle(Color.red)
                    .textStyle(.heading)
            },
            placeholder: "Add text here",
            html: .constant("Some text entered"),
            uploadParameters: uploadParameters
        )
    }
}

#endif
