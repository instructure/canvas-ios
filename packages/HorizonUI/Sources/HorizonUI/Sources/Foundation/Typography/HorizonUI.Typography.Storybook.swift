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
public extension HorizonUI.Typography {
    struct Storybook: View {
        private let text = "This is an example text."

        public var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(HorizonUI.Typography.Name.allCases) { typography in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(typography)")
                                .font(typography.font)                           
                            Text(text)
                                .huiTypography(typography.id)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.all, 16)
            .navigationTitle("Typography")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

extension HorizonUI.Typography.Name: Identifiable {
    public var id: Self { self }
}

#Preview {
    HorizonUI.Typography.Storybook()
}
