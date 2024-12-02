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
public extension HorizonUI.CornerRadius {
    struct Storybook: View {
        public var body: some View {
            VStack(spacing: 16) {
                ForEach(HorizonUI.CornerRadius.allCases) { type in
                    VStack(spacing: 4) {
                        Text(verbatim: "\(type.levelString) - \(Int(type.rawValue)) px")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundStyle(Color.huiColors.primitives.blue45)
                                .huiCornerRadius(type: type)
                                .frame(width: 120, height: 56, alignment: .leading)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            .padding(.all, 16)
            .navigationTitle("Corner Radius")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

extension HorizonUI.CornerRadius: Identifiable {
    public var id: Self { self }
    var levelString: String {
        let str = "\(id)"
        let components = str.components(separatedBy: "level")
        return "Level \(components[1])"
    }
}

#Preview {
    HorizonUI.CornerRadius.Storybook()
}
