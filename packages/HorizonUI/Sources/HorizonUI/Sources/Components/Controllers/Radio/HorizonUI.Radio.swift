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

public extension HorizonUI {
    struct Radio: View {
        // MARK: - Dependencies

        @Binding private var isOn: Bool
        private let title: String
        private let description: String?
        private let errorMessage: String?
        private let isRequired: Bool
        private let isDisabled: Bool

        public init(
            isOn: Binding<Bool>,
            title: String,
            description: String? = nil,
            errorMessage: String? = nil,
            isRequired: Bool = false,
            isDisabled: Bool = false
        ) {
            self._isOn = isOn
            self.title = title
            self.description = description
            self.errorMessage = errorMessage
            self.isRequired = isRequired
            self.isDisabled = isDisabled
        }

        public var body: some View {
            Toggle(isOn: $isOn) {
                HorizonUI.ToggleDescriptionView(
                    title: title,
                    description: description,
                    errorMessage: errorMessage,
                    isRequired: isRequired
                )
            }
            .toggleStyle(RadioButtonStyle())
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
        }
    }
}

#Preview {
    HorizonUI.Radio(isOn: .constant(true), title: "Content")
}

fileprivate extension HorizonUI {
    struct RadioButtonStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .top, spacing: .huiSpaces.primitives.xxSmall) {
                Button {
                    configuration.isOn.toggle()
                } label: {
                    radioIcon
                }
                .foregroundStyle(
                    configuration.isOn
                    ? Color.huiColors.icon.default
                    : Color.huiColors.lineAndBorders.containerStroke
                )

                configuration.label
            }

            var radioIcon: Image {
                configuration.isOn ? Image.huiIcons.radioButtonChecked : Image.huiIcons.radioButtonUnchecked
            }
        }
    }
}
