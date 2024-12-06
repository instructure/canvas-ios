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
import Core

struct ModulePrerequisiteLine: View {
    // MARK: - Dependencies

    let isFirstItem: Bool
    let isLastItem: Bool
    let firstItemLineHeight: CGFloat
    let lastItemLineHeight: CGFloat
    let hasMultipleItems: Bool

    var body: some View {
        if hasMultipleItems {
            Rectangle()
                .fill(Color.backgroundDark)
                .frame(width: 1)
                .offset(y: isFirstItem ? (firstItemLineHeight / 2) : 0)
                .overlay(alignment: .bottom) {
                    if isLastItem {
                        Rectangle()
                            .fill(Color.backgroundLightest)
                            .frame(width: 1, height: lastItemLineHeight / 2)
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        ModulePrerequisiteLine(
            isFirstItem: true,
            isLastItem: false,
            firstItemLineHeight: 50,
            lastItemLineHeight: 50,
            hasMultipleItems: true
        )
    }
}
#endif
