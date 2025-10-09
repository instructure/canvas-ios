//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import HorizonUI

struct PaginationIndicatorView: View {
    
    @Binding var currentIndex: Int?
    let count: Int
    
    var body: some View {
        HStack(spacing: .huiSpaces.space4) {
            ForEach(0 ..< count, id: \.self) { index in
                Circle()
                    .fill(index == (currentIndex ?? 0) ? Color.huiColors.icon.medium : Color.clear)
                    .stroke(Color.huiColors.icon.medium, lineWidth: 1)
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
        .padding(.horizontal, .huiSpaces.space24)
    }

}
