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

    public struct TextFieldCell: View {
        private let label: Text?
        private let placeholder: String

        @Binding private var text: String

        public init(label: Text, placeholder: String, text: Binding<String>) {
            self.label = label
            self.placeholder = placeholder
            self._text = text
        }

        public init(label: String? = nil, placeholder: String, text: Binding<String>) {
            self.label = label.map { Text($0) }
            self.placeholder = placeholder
            self._text = text
        }

        public var body: some View {
            VStack(spacing: 0) {
                SwiftUI.Group {
                    if let label {
                        HStack(spacing: 0) {
                            label
                                .accessibility(hidden: true)
                            Spacer()
                            textField
                        }
                    } else {
                        textField
                    }
                }
                .paddingStyle(.leading, .standard)
                .paddingStyle(.trailing, .standard)
                .paddingStyle(.top, .cellTop)
                .paddingStyle(.bottom, .cellBottom)

                InstUI.Divider()
            }
        }

        private var textField: some View {
            TextField(placeholder, text: $text)
                .multilineTextAlignment(label == nil ? .leading : .trailing)
                .font(label == nil ? .semibold16 : .regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
                .accessibility(label: label ?? Text(placeholder)) // TODO
        }
    }
}

#if DEBUG

#Preview {
    InstUI.TextFieldCell(placeholder: "Add text here", text: .constant(""))
}

#endif
