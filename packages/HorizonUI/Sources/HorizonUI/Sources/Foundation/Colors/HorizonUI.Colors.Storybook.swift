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

// TODO: Make it #if DEBUG later
public extension HorizonUI.Colors {
    struct Storybook: View {
        public var body: some View {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 40))],
                spacing: 16
            ) {
                Section(
                    header: headerView("UI and Additional Primitives")
                ) {
                    ForEach(Color.huiColors.primitives.allColors) { color in
                        VStack(spacing: 4) {
                            Text(color.name).font(.system(size: 8))
                            Circle().foregroundStyle(color.code)
                        }
                    }
                }
                Spacer(minLength: 16)
                Section(
                    header: headerView("UI Colors")
                ) {
                    ForEach(Color.huiColors.ui.allColors) { color in
                        VStack(spacing: 4) {
                            Text(color.name).font(.system(size: 8))
                            Circle().foregroundStyle(color.code)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.all, 16)
            .navigationTitle("Colors")
            .navigationBarTitleDisplayMode(.large)
        }

        @ViewBuilder
        private func headerView(_ title: String) -> some View {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct ColorWithID: Identifiable, Sendable {
        let name: String
        let code: Color

        init(_ name: String, _ code: Color) {
            self.name = name
            self.code = code
        }

        public var id: String { name }
    }
}

#Preview {
    HorizonUI.Colors.Storybook()
}