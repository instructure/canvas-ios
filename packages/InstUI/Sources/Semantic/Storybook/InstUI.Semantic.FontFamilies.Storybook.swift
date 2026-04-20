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

public extension InstUI.Semantic.FontFamilies {

    struct Storybook: View {
        private let theme = InstUI.Theme.default

        public var body: some View {
            List {
                ForEach(theme.fontFamilies.all, id: \.name) { family in
                    Section {
                        Text(verbatim: "weight")
                            .font(.system(size: 11, design: .monospaced))
                            .frame(width: 110, alignment: .leading)
                        ForEach(theme.fontWeights.all, id: \.name) { weight in
                            HStack(spacing: 12) {
                                Text(verbatim: (weight.name))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 110, alignment: .leading)
                                Text(verbatim: "The quick brown fox")
                                    .font(.custom(family.value, size: 16))
                                    .fontWeight(weight.value)
                            }
                        }
                    } header: {
                        Text(verbatim: "\(family.name) family")
                            .font(.custom(family.value, size: 22))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .textCase(nil)
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Semantic Font Families"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    NavigationStack {
        InstUI.Semantic.FontFamilies.Storybook()
    }
}
