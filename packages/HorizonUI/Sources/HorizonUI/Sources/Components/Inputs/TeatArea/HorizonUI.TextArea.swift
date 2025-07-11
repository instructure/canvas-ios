//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Observation
import SwiftUI

extension HorizonUI {
    public struct TextArea: View {

        @FocusState private var focused: Bool

        // MARK: - Properties

        private let autoExpand: Bool
        private let error: String?
        private let helperText: String?
        private let label: String?
        private let placeholder: String?
        @Binding var text: String
        private let disabled: Bool

        // MARK: - Init

        public init(
            _ text: Binding<String>,
            label: String? = nil,
            error: String? = nil,
            helperText: String? = nil,
            placeholder: String? = nil,
            disabled: Bool = false,
            focused: FocusState<Bool>? = nil,
            autoExpand: Bool = false
        ) {
            self.error = error
            self.helperText = helperText
            self.label = label
            self.placeholder = placeholder
            self._text = text
            self.disabled = disabled
            self._focused = focused ?? FocusState()
            self.autoExpand = autoExpand
        }

        // MARK: - Body

        public var body: some View {
            VStack(alignment: .leading) {
                labelText
                textFieldContainer
                ZStack {
                    errorView
                    helperTextView
                }
            }
            .padding(1)
        }

        // MARK: - Private

        @ViewBuilder
        private var errorView: some View {
            if let error = error {
                HStack(spacing: 0) {
                    Image.huiIcons.error.foregroundColor(Color.huiColors.text.error)
                    Text(error)
                        .huiTypography(.p2)
                        .foregroundColor(Color.huiColors.text.error)
                }
                .opacity(isErrorEmpty ? 0 : 1)
                .animation(.easeInOut, value: error)
                .padding(.leading, .huiSpaces.space4)
            }
        }

        @ViewBuilder
        private var helperTextView: some View {
            if let helperText = helperText {
                Text(helperText)
                    .huiTypography(.p2)
                    .foregroundColor(Color.huiColors.text.body)
                    .padding(.leading, 5)
                    .opacity(isHelperTextVisible ? 1 : 0)
                    .animation(.easeInOut, value: helperText)
            }
        }

        private var isErrorEmpty: Bool {
            error?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        }

        private var isHelperTextVisible: Bool {
            !(helperText?.isEmpty ?? true) && isErrorEmpty
        }

        @ViewBuilder
        private var labelText: some View {
            if let label = self.label {
                Text(label)
                    .huiTypography(.labelLargeBold)
                    .padding(.leading, 5)
            }
        }

        private var textField: some View {
            let cornerRadius = HorizonUI.CornerRadius.level1_5.attributes.radius
            let view = autoExpand ?
                AnyView(TextField("", text: $text, axis: .vertical).lineLimit(1 ... 10)) :
                AnyView(TextEditor(text: $text))
            return view
                .padding(.huiSpaces.space12)
                .huiTypography(.p1)
                .background(Color.huiColors.surface.pageSecondary)
                .focused($focused)
                .disabled(disabled)
                .cornerRadius(cornerRadius)
                .overlay(
                    ZStack {
                        Text(placeholder ?? "")
                            .foregroundColor(Color.huiColors.text.placeholder)
                            .padding(.leading, .huiSpaces.space8)
                            .padding(.top, .huiSpaces.space12)
                            .opacity(text.isEmpty && !focused ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            textFieldBorderColor,
                            lineWidth: HorizonUI.Borders.level1.rawValue
                        )
                        .animation(.easeInOut, value: textFieldBorderColor)
                )
        }

        private var textFieldBorderColor: Color {
            isErrorEmpty ? Color.huiColors.lineAndBorders.containerStroke : Color.huiColors.surface.error
        }

        private var textFieldContainer: some View {
            textField
                .padding(3)
                .overlay(
                    RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius + 2)
                        .stroke(
                            textFieldContainerBorderColor,
                            lineWidth: HorizonUI.Borders.level2.rawValue
                        )
                        .opacity(focused ? 1.0 : 0.0)
                        .animation(.easeInOut, value: focused)
                        .animation(.easeInOut, value: textFieldContainerBorderColor)
                )
                .opacity(disabled ? 0.5 : 1.0)
        }

        private var textFieldContainerBorderColor: Color {
            isErrorEmpty ? Color.huiColors.surface.institution : Color.huiColors.surface.error
        }
    }
}
