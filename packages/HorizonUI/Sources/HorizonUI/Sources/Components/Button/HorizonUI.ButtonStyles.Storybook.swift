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

extension HorizonUI.ButtonStyles {
    private struct StorybookConfiguration: Identifiable {
        var id: String { title }

        let isSmall: Bool
        let isDisabled: Bool
        let title: String
    }

    struct Storybook: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(
                        [
                            StorybookConfiguration(
                                isSmall: false,
                                isDisabled: false,
                                title: "Regular Height - Relative Width Buttons"
                            ),
                            StorybookConfiguration(
                                isSmall: true, isDisabled: false, title: "Small Height - Block Width Buttons"),
                            StorybookConfiguration(isSmall: false, isDisabled: true, title: "Disabled Buttons"),
                        ]
                    ) { storybookConfiguration in
                        section(storybookConfiguration)
                    }
                    .padding(16)
                }
                .background(Color(red: 88 / 100, green: 88 / 100, blue: 88 / 100))
                .navigationTitle("Buttons")
                .navigationBarTitleDisplayMode(.large)
            }
        }

        private func section(_ storybookConfiguration: StorybookConfiguration) -> some View {
            Section(header: header(storybookConfiguration.title)) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(HorizonUI.ButtonStyles.ButtonType.allCases) { type in
                        row(
                            type: type, isSmall: storybookConfiguration.isSmall,
                            isDisabled: storybookConfiguration.isDisabled)
                    }
                }
            }
        }

        private func row(
            type: HorizonUI.ButtonStyles.ButtonType,
            isSmall: Bool,
            isDisabled: Bool
        ) -> some View {
            HStack(spacing: 16) {
                HorizonUI.IconButton(
                    HorizonUI.icons.add,
                    type: type,
                    isSmall: isSmall
                ) {}
                .disabled(isDisabled)

                HorizonUI.PrimaryButton(
                    "\(type.rawValue) Button",
                    type: type,
                    isSmall: isSmall,
                    fillsWidth: isSmall
                ) {}
                .disabled(isDisabled)

                HorizonUI.TextButton(
                    "\(type.rawValue) Button",
                    type: type,
                    fillsWidth: isSmall
                ) {}
                .disabled(isDisabled)
            }
        }

        private func header(_ title: String) -> some View {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
        }
    }
}

#Preview {
    HorizonUI.ButtonStyles.Storybook()
}
