//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public extension InstUI.Semantic.Opacity {

    struct Storybook: View {

        public var body: some View {
            List(entries) { entry in
                HStack(spacing: 12) {
                    Text(verbatim: entry.name)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 80, alignment: .leading)
                    Text(verbatim: entry.formattedValue)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .leading)
                    Rectangle()
                        .frame(width: 44, height: 22)
                        .foregroundStyle(.black)
                        .opacity(entry.value)
                        .background {
                            Image.checkeredTile
                                .resizable(resizingMode: .tile)
                        }
                        .overlay(Rectangle().strokeBorder(.gray, lineWidth: 1))
                    Spacer()
                }
            }
            .navigationTitle(Text(verbatim: "Semantic Opacities"))
            .navigationBarTitleDisplayMode(.large)
        }

        private var entries: [OpacityEntry] {
            InstUI.Theme.default.opacity.all.map { OpacityEntry(name: $0.name, value: $0.value) }
        }
    }
}

private struct OpacityEntry: Identifiable {
    let name: String
    let value: Double
    var id: String { name }

    var formattedValue: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}

#Preview {
    NavigationStack {
        InstUI.Semantic.Opacity.Storybook()
    }
}
