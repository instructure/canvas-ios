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

        private let label: Label?
        private let placeholder: String

        @Binding private var text: String

        public init(label: Label?, placeholder: String, text: Binding<String>) {
            self.label = label
            self.placeholder = placeholder
            self._text = text
        }

        public init(placeholder: String, text: Binding<String>) where Label == Text? {
            self.init(label: nil, placeholder: placeholder, text: text)
        }

        public var body: some View {
            VStack(spacing: 0) {
                SwiftUI.Group {
                    if let label {
                        HStack(spacing: 0) {
                            label
                                .textStyle(.cellLabel)
                                .accessibility(hidden: true)
                            Spacer()
                            textField
                        }
                    } else {
                        textField
                    }
                }
                .paddingStyle(set: .standardCell)

                InstUI.Divider()
            }
        }

        private var textField: some View {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.placeholderGray))
                .multilineTextAlignment(label == nil ? .leading : .trailing)
                .font(label == nil ? .semibold16 : .regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
                .submitLabel(.done)
                .accessibility(label: label as? Text ?? Text(placeholder)) // TODO
        }
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.Divider()
        InstUI.TextFieldCell(placeholder: "Add text here", text: .constant(""))
        InstUI.TextFieldCell(label: Text(verbatim: "Label"), placeholder: "Add text here", text: .constant(""))
        InstUI.TextFieldCell(label: Text(verbatim: "Styled Label").foregroundStyle(Color.green), placeholder: "Add text here", text: .constant("Some text entered"))
    }
}

#endif