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

import Core
import SwiftUI

struct SpeedGraderButton: View {
    @Environment(\.isEnabled) private var isEnabled
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.regular16)
                .padding(.bottom, 1)
                .padding(.vertical, 8)
                .padding(.horizontal, 17)
                .frame(maxWidth: .infinity)
                .cornerRadius(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .inset(by: 0.5)
                        .stroke(.tint)
                )
        }
        .customTint(isEnabled ? nil : Color.disabledGray)
    }
}

#if DEBUG

#Preview {
    HStack(spacing: 16) {
        SpeedGraderButton(title: "No Grade") { }
            .tint(.red)
            .disabled(true)
        SpeedGraderButton(title: "Excuse Student") { }
            .tint(.blue)
    }
    .padding()
}

#endif
