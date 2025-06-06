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
public extension HorizonUI.Elevations {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(HorizonUI.Elevations.allCases) { level in
                        VStack(spacing: 8) {
                            Text(verbatim: level.details)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack(spacing: 0) {
                                Rectangle()
                                    .foregroundStyle(Color.white)
                                    .huiElevation(level: level)
                                    .frame(width: 120, height: 56, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.all, 16)
            }
            .navigationTitle("Elevation / Shadows")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

extension HorizonUI.Elevations: Identifiable {
    public var id: Self { self }
    var details: String {
        let str = "\(id)"
        let components = str.components(separatedBy: "level")
        let attributesString = "x: \(Int(attributes.x)), y: \(Int(attributes.y)), blur: \(Int(attributes.blur)), spread: \(Int(attributes.spread))"
        return "Level \(components[1]) - \(attributesString)"
    }
}

#Preview {
    HorizonUI.Elevations.Storybook()
}
