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

struct CertificateProgressBar: View {
    let maxWidth: Double
    let progress: Double
    let progressString: String

    var body: some View {
        Rectangle()
            .fill(Color.backgroundMedium)
            .frame(width: maxWidth, height: 25)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.backgroundDarkest)
                    .frame(
                        width: progress * maxWidth,
                        height: 25
                    )
                    .overlay(alignment: .trailing) {
                        Text(progressString)
                            .font(.regular12)
                            .foregroundStyle(Color.textLightest)
                            .padding(.trailing, 6)
                    }
            }
            .padding(.top, 16)
            .animation(.easeIn, value: progress)
    }
}

#Preview {
    CertificateProgressBar(
        maxWidth: 450,
        progress: 0.75,
        progressString: "75%"
    )
}
