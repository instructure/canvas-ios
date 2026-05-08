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
import UIKit

public extension InstUI.Semantic.Color {

    struct Storybook: View {

        public var body: some View {
            List {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(entry.color)
                                    .background {
                                        if entry.hasAlpha {
                                            Image.checkeredTile
                                                .resizable(resizingMode: .tile)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        }
                                    }
                                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(.gray.opacity(0.3), lineWidth: 0.5))
                                    .frame(width: 36, height: 36)
                                Text(verbatim: entry.displayName)
                                    .font(.system(size: 12, design: .monospaced))
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Semantic Colors"))
            .navigationBarTitleDisplayMode(.large)
        }

        private var sections: [ColorSection] {
            let grouped = Dictionary(grouping: InstUI.Theme.default.color.all) { entry in
                entry.name.components(separatedBy: ".").first ?? entry.name
            }
            return grouped.keys.sorted().map { key in
                ColorSection(
                    title: key,
                    entries: grouped[key]!.map { ColorEntry(sectionTitle: key, name: $0.name, color: $0.value) }
                )
            }
        }
    }
}

private struct ColorSection: Identifiable {
    let title: String
    let entries: [ColorEntry]
    var id: String { title }
}

private struct ColorEntry: Identifiable {
    let displayName: String
    let color: Color
    let hasAlpha: Bool
    var id: String { displayName }

    init(sectionTitle: String, name: String, color: Color) {
        let prefix = sectionTitle + "."
        self.displayName = name.hasPrefix(prefix) ? String(name.dropFirst(prefix.count)) : name
        self.color = color
        self.hasAlpha = UIColor(color).cgColor.alpha < 1
    }
}

#Preview {
    NavigationStack {
        InstUI.Semantic.Color.Storybook()
    }
}
