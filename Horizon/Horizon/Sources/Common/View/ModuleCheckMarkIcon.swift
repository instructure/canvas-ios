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

struct ModuleCheckMarkIcon: View {
    let isCompleted: Bool

    var body: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)

                Image(systemName: "checkmark")
                    .font(.regular10)
                    .foregroundColor(.backgroundLightest)
            } else {
                Circle()
                    .stroke(Color.backgroundDark, lineWidth: 1)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

#if DEBUG
#Preview {
    ModuleCheckMarkIcon(isCompleted: true)
}
#endif
