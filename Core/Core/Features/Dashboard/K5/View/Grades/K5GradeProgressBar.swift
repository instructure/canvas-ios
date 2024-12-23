//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct K5GradeProgressBar: View {
    @State var percentage: Double
    @State var color: Color
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.clear)
                    .border(color, width: 1)
                let clampedPercentage = min(max(percentage, 0), 100)
                Rectangle().frame(width: abs(min(CGFloat(clampedPercentage) / 100.0 * geometry.size.width, geometry.size.width)),
                                  height: geometry.size.height, alignment: .leading)
                    .foregroundColor(color)
                    // .animation(animate ? .spring(response: 0.55, dampingFraction: 0.55, blendDuration: 0.55) : .none)
            }.clipped()
        }
         .onAppear {
            animate = true
        }.onDisappear {
            animate = false
        }
    }
}

#if DEBUG

struct K5GradeProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        K5GradeProgressBar(percentage: 50, color: .red).frame(height: 16)
    }
}

#endif
