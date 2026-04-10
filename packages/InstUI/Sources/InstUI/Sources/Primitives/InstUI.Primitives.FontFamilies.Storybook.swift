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
            List(InstUI.Primitives.FontFamilies.all, id: \.name) { family in
                Section(header: Text(verbatim: family.name).font(.system(size: 12, design: .monospaced))) {
                    ForEach(InstUI.Primitives.FontWeights.all, id: \.name) { weight in
                        HStack(spacing: 12) {
                            Text(verbatim: weight.name)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text(verbatim: "The quick brown fox jumps\nover the lazy dog")
                                .font(.custom(family.family, size: 16))
                                .fontWeight(weight.weight)
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: "Primitive Font Families"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    NavigationStack {
        InstUI.Primitives.FontFamilies.Storybook()
    }
}
