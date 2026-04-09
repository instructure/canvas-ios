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

public extension InstUI.Primitives.FontFamilies {

    struct Storybook: View {
        public var body: some View {
            List(families) { family in
                Section(header: Text(verbatim: family.name).font(.system(size: 12, design: .monospaced))) {
                    ForEach(weights) { weight in
                        HStack(spacing: 12) {
                            Text(verbatim: weight.name)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text(verbatim: "The quick brown fox jamps")
                                .font(.custom(family.fontName, size: 16))
                                .fontWeight(weight.weight)
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Primitive Font Families"))
            .navigationBarTitleDisplayMode(.large)
        }

        private let families: [FamilyEntry] = Mirror(reflecting: InstUI.Primitives.fontFamilies)
            .children
            .compactMap { child in
                guard
                    let name = child.label,
                    let fontName = child.value as? String
                else { return nil }

                return FamilyEntry(name: name, fontName: fontName)
            }

        private let weights: [WeightEntry] = Mirror(reflecting: InstUI.Primitives.FontWeights())
            .children
            .compactMap { child in
                guard
                    let name = child.label,
                    let weight = child.value as? Font.Weight
                else { return nil }

                return WeightEntry(name: name, weight: weight)
            }
    }

    private struct FamilyEntry: Identifiable {
        let name: String
        let fontName: String
        var id: String { name }
    }

    private struct WeightEntry: Identifiable {
        let name: String
        let weight: Font.Weight
        var id: String { name }
    }
}

#Preview {
    NavigationStack {
        InstUI.Primitives.FontFamilies.Storybook()
    }
}
