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
    struct Storybook: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Section(header: header("Regular Height - Relative Width Buttons")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Button("Black Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.black(
                                        leading: HorizonUI.icons.addCircle,
                                        trailing: HorizonUI.icons.addCircle
                                    )
                                )

                            Button("White Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.white(
                                        leading: HorizonUI.icons.addCircle,
                                        trailing: HorizonUI.icons.addCircle
                                    )
                                )
                                .huiElevation(level: .level3)

                            Button("AI Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.ai())

                            Button("Blue Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.blue())

                            Button("Beige Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.beige())
                                .huiElevation(level: .level3)
                        }
                    }

                    Section(header: header("Small Height - Block Width Buttons")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Button("Small Black Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.black(
                                        isSmall: true,
                                        fillsWidth: true
                                    )
                                )
                            Button("Small White Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.white(
                                        isSmall: true,
                                        fillsWidth: true
                                    )
                                )
                                .huiElevation(level: .level3)
                            Button("Small AI Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.ai(
                                        isSmall: true,
                                        fillsWidth: true
                                    )
                                )
                            Button("Small Blue Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.blue(
                                        isSmall: true,
                                        fillsWidth: true
                                    )
                                )
                            Button("Small Beige Button") {}
                                .buttonStyle(
                                    HorizonUI.ButtonStyles.beige(
                                        isSmall: true,
                                        fillsWidth: true
                                    )
                                )
                                .huiElevation(level: .level3)
                        }
                    }

                    Section(header: header("Disabled Buttons")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Button("Disabled Black Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.black())
                                .disabled(true)
                            Button("Disabled White Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.white())
                                .disabled(true)
                                .huiElevation(level: .level3)
                            Button("Disabled AI Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.ai())
                                .disabled(true)
                            Button("Disabled Blue Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.blue())
                                .disabled(true)
                            Button("Disabled Beige Button") {}
                                .buttonStyle(HorizonUI.ButtonStyles.beige())
                                .disabled(true)
                                .huiElevation(level: .level3)
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Buttons")
            .navigationBarTitleDisplayMode(.large)
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
