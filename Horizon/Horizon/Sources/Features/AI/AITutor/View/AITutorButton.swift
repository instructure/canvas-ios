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

struct AITutorButton: View {
    let item: AITutorType
    let onSelect: (AITutorType) -> Void

    var body: some View {
        Button {
            onSelect(item)
        } label: {
            labelButton
        }
    }

    private var labelButton: some View {
        Text(item.titel)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.4))
            )
    }
}

#if DEBUG
#Preview {
    AITutorButton(item: .summary, onSelect: { _ in})
}
#endif
