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
    struct ToggleItem: View {
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
            VStack {
                Toggle(isOn: $isOn) {
                    HorizonUI.Controls.ToggleDescriptionView(
                        title: title,
                        description: description,
                        errorMessage: errorMessage,
                        isRequired: isRequired
                    )
                }
                .toggleStyle(ToggleItemStyle(alignment: alignment))
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1)
            }
        }

        private var alignment: VerticalAlignment {
            (description != nil || errorMessage != nil) ? .top : .center
        }
    }
}

#Preview {
    HorizonUI.Controls.ToggleItem(isOn: .constant(true),
                         title: "Title",
                         description: "Description",
                         isRequired: true,
                         isDisabled: true)
}


fileprivate extension HorizonUI.Controls {
    struct ToggleItemStyle: ToggleStyle {
        let alignment: VerticalAlignment

        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: alignment, spacing: .huiSpaces.space4) {
                Rectangle()
                    .fill(contentColor)
                    .huiCornerRadius(level: .level4)
                    .overlay {
                        Circle()
                            .fill(Color.huiColors.surface.pageSecondary)
                            .padding(.huiSpaces.space2)
                            .animation(.spring, value: configuration.isOn)
                            .overlay {
                                configuration.isOn ? Image.huiIcons.checkSmall : Image.huiIcons.closeSmall
                            }
                            .offset(x: configuration.isOn ? 8 : -8)
                    }
                    .frame(width: 40, height: 24)
                    .foregroundStyle(contentColor)
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }

                configuration.label
            }

            var contentColor: Color {
                configuration.isOn ? Color.huiColors.icon.default : Color.huiColors.icon.medium
            }
        }
    }
}
