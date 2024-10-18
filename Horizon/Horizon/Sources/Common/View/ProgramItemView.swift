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

import Core
import SwiftUI

struct ProgramItemView: View {
    let title: String
    let subtitle: String
    let duration: String

    var body: some View {
        VStack {
            Size14RegularTextDarkestTitle(title: title)
                .padding(.bottom, 8)
            HStack(spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "document")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.textDark)
                        .frame(width: 18, height: 18)
                    Size12RegularTextDarkTitle(title: subtitle)
                        .lineLimit(2)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.textDark)
                        .frame(width: 14, height: 14)
                    Size12RegularTextDarkTitle(title: "20 Mins")
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        ProgramItemView(
            title: "Getting into Business",
            subtitle: "Page",
            duration: "55 mins"
        )
    }
}
