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

public extension HorizonUI.Controls {
    struct Checkbox: View {
        public enum Style {
            case `default`
            case partial
            case error
        }

        // MARK: - Dependencies

        @Binding private var isOn: Bool
        private let style: Style
        private let title: String
        private let description: String?
        private let errorMessage: String?
        private let isRequired: Bool
        private let isDisabled: Bool

        public init(
            isOn: Binding<Bool>,
            style: Style,
            title: String,
            description: String? = nil,
            errorMessage: String? = nil,
            isRequired: Bool = false,
            isDisabled: Bool = false
        ) {
            self._isOn = isOn
            self.style = style
            self.title = title
            self.description = description
            self.errorMessage = errorMessage
            self.isRequired = isRequired
            self.isDisabled = isDisabled
        }

        public var body: some View {
            Toggle(isOn: $isOn) {
                HorizonUI.Controls.ToggleDescriptionView(
                    title: title,
                    description: description,
                    errorMessage: errorMessage,
                    isRequired: isRequired
                )
            }
            .toggleStyle(CheckboxStyle(style: style))
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
        }
    }
}

#Preview {
    HorizonUI.Controls.Checkbox(
        isOn: .constant(true),
        style: .default,
        title: "Title",
        description: "Description",
        isRequired: true,
        isDisabled: true
    )
}

fileprivate extension HorizonUI.Controls {
    struct CheckboxStyle: ToggleStyle {
        let style: HorizonUI.Controls.Checkbox.Style

        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .top, spacing: .huiSpaces.primitives.xxSmall) {
                Button {
                    configuration.isOn.toggle()
                } label: {
                    configuration.isOn ? checkedImage : Image.huiIcons.checkBoxOutlineBlank
                }
                .foregroundStyle(
                    style == .error
                        ? Color.huiColors.icon.error
                        : toggleColor
                )

                configuration.label
            }

            var toggleColor: Color {
                configuration.isOn ? .huiColors.icon.default : .huiColors.lineAndBorders.containerStroke
            }
        }

        private var checkedImage: Image {
            style == .default ? Image.huiIcons.checkBox : Image.huiIcons.indeterminateCheckBox
        }
    }
}
