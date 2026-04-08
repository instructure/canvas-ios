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

public extension InstUI.Primitives.Sizes {

    struct Storybook: View {
        private let sizes: [SizeEntry] = Mirror(reflecting: InstUI.Primitives.Sizes())
            .children
            .compactMap { child in
                guard let name = child.label, let value = child.value as? CGFloat else { return nil }
                return SizeEntry(name: name, value: value)
            }

        public var body: some View {
            List(sizes) { entry in
                HStack(spacing: 12) {
                    Text(verbatim: entry.name)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 90, alignment: .leading)
                    Text(verbatim: "\(entry.formattedValue) pt")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 48, alignment: .leading)
                    Rectangle()
                        .frame(width: min(entry.value, 200), height: 8)
                        .foregroundStyle(.blue)
                    Spacer()
                }
            }
            .navigationTitle(Text(verbatim: "Primitive Sizes"))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    struct SizeEntry: Identifiable {
        let name: String
        let value: CGFloat
        public var id: String { name }

        var formattedValue: String {
            value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value))
                : String(Double(value))
        }
    }
}

#Preview {
    NavigationStack {
        InstUI.Primitives.Sizes.Storybook()
    }
}
