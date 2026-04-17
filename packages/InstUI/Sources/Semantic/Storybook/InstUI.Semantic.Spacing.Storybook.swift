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

public extension InstUI.Semantic.Spacing {

    struct Storybook: View {
        @Environment(\.instUITheme) private var theme

        public var body: some View {
            List {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            HStack(spacing: 8) {
                                Text(verbatim: entry.name)
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(width: 180, alignment: .leading)
                                Text(verbatim: "\(entry.formattedValue) pt")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 44, alignment: .leading)
                                Rectangle()
                                    .frame(width: min(entry.value, 100), height: 8)
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Semantic Spacing"))
            .navigationBarTitleDisplayMode(.large)
        }

        private var sections: [TokenSection] {
            let grouped = Dictionary(grouping: theme.spacing.all) { entry in
                entry.name.contains(".")
                    ? entry.name.components(separatedBy: ".").first ?? entry.name
                    : "spacing"
            }
            return grouped.keys.sorted().map { key in
                TokenSection(
                    title: key,
                    entries: grouped[key]!.map { SpacingEntry(sectionTitle: key, name: $0.name, value: $0.value) }
                )
            }
        }
    }
}

private struct TokenSection: Identifiable {
    let title: String
    let entries: [SpacingEntry]
    var id: String { title }
}

private struct SpacingEntry: Identifiable {
    let name: String
    let value: CGFloat
    var id: String { name }

    init(sectionTitle: String, name: String, value: CGFloat) {
        let prefix = sectionTitle + "."
        self.name = name.hasPrefix(prefix) ? String(name.dropFirst(prefix.count)) : name
        self.value = value
    }

    var formattedValue: String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(Double(value))
    }
}

#Preview {
    NavigationStack {
        InstUI.Semantic.Spacing.Storybook()
    }
}
