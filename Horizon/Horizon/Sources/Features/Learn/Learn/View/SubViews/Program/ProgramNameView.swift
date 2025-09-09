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

import HorizonUI
import SwiftUI

struct ProgramNameView: View {
    let name: String
    var body: some View {
        HStack(spacing: .huiSpaces.space4) {
            Text("Part of", bundle: .horizon)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(alignment: .leading)

                Text(name)
                    .huiTypography(.buttonTextLarge)
                    .foregroundStyle(Color.huiColors.text.body)
                    .overlay(
                        Rectangle()
                            .fill(Color.huiColors.text.body)
                            .frame(height: 1)
                            .frame(maxHeight: .infinity, alignment: .bottom),
                        alignment: .bottomLeading
                    )
            Spacer()
        }
    }
}

#Preview {
    ProgramNameView(name: "Here Lorem Ipsum Dolor Sit Amet Adipiscing")
}
