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
    let screenWidth: Double
    let title: String
    let icon: Image
    let duration: String
    let certificate: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            icon
                .frame(width: 18, height: 18)
            Text(title)
                .font(.regular16)
                .lineLimit(2)
                .foregroundStyle(Color.textDarkest)
                .padding(.top, 4)
            Text(duration.uppercased())
                .font(.regular12)
                .foregroundStyle(Color.textDark)
            if let certificate {
                Text(certificate.uppercased())
                    .font(.regular12)
                    .lineLimit(2)
                    .foregroundStyle(Color.textDarkest)
            }
        }
        .padding(.all, 16)
        .frame(width: (screenWidth - 16 - 8) / 2 - 4, alignment: .leading)
        .frame(minHeight: certificate == nil ? 90 : 110)
        .background(Color.backgroundLight)
    }
}

#Preview {
    HStack(spacing: 8) {
        ProgramItemView(
            screenWidth: 400,
            title: "Practice Quiz",
            icon: Image(systemName: "doc"),
            duration: "55 mins",
            certificate: "BIOLOGY #1573"
        )
        ProgramItemView(
            screenWidth: 400,
            title: "Practice Quiz",
            icon: Image(systemName: "doc"),
            duration: "55 mins",
            certificate: "BIOLOGY #1573"
        )
    }
}

#Preview {
    ProgramItemView(
        screenWidth: 400,
        title: "Video Quiz",
        icon: Image(systemName: "doc"),
        duration: "20 mins",
        certificate: nil
    )
}
