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
    public struct TextInput: View {

        @FocusState private var focused: Bool

        // MARK: - Properties

        private let error: String?
        private let helperText: String?
        private let label: String?
        private let placeholder: String?
        @Binding var text: String
        private let disabled: Bool
        private let small: Bool
        private let trailing: AnyView?

        // MARK: - Init

        public init(
            _ text: Binding<String>,
            label: String? = nil,
            error: String? = nil,
            helperText: String? = nil,
            placeholder: String? = nil,
            disabled: Bool = false,
            small: Bool = false,
            trailing: (any View)? = nil,
            focused: FocusState<Bool>? = nil
        ) {
            self.error = error
            self.helperText = helperText
            self.label = label
            self.placeholder = placeholder
            self._text = text
            self.disabled = disabled
            self.small = small
            self.trailing = trailing.map { AnyView($0) }
            self._focused = focused ?? FocusState()
        }

        // MARK: - Body

        public var body: some View {
            VStack(alignment: .leading) {
                labelText
                ZStack(alignment: .trailing) {
                    textFieldContainer
                    if let trailing = trailing {
                        trailing
                            .padding(.trailing, 15)
                    }
                }
                ZStack {
                    errorView
                    helperTextView
                }
            }
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
                .padding(.leading, 5)
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
            TextField(
                placeholder ?? "",
                text: $text
            )
            .padding(.huiSpaces.primitives.small)
            .padding(.trailing, 30)
            .frame(height: textFieldHeight)
            .huiTypography(textFieldTypography)
            .overlay(
                RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                    .stroke(
                        textFieldBorderColor,
                        lineWidth: HorizonUI.Borders.level1.rawValue
                    )
                    .animation(.easeInOut, value: textFieldBorderColor)
            )
            .background(Color.huiColors.surface.pageSecondary)
            .focused($focused)
            .disabled(disabled)
        }

        private var textFieldHeight: CGFloat {
            small ? 34 : 44
        }

        private var textFieldTypography: HorizonUI.Typography.Name {
            small ? .p1 : .buttonTextLarge
        }

        private var textFieldBorderColor: Color {
            isErrorEmpty ? Color.huiColors.lineAndBorders.containerStroke : Color.huiColors.surface.error
        }

        private var textFieldContainer: some View {
            textField
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

#Preview {
    @Previewable @State var text = ""
    let disabled = false
    let error: String? = nil
    let small = true

    ScrollView {
        VStack {
            HorizonUI.TextInput(
                $text,
                label: "Hello, World!",
                error: error,
                helperText: "This is some helper text",
                placeholder: "Placeholder text",
                disabled: disabled,
                small: small,
                trailing: Image.huiIcons.chevronRight
            )
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    .background(Color.huiColors.surface.pagePrimary)
}
