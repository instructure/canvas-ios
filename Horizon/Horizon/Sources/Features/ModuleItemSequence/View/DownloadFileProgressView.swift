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

struct DownloadFileProgressView: View {
    let progress: Double
    var errorMessage: String? = "We encountered an error"
    let onTapCance: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            HorizonUI.ProgressBar(
                progress: progress,
                size: .medium,
                numberPosition: .outside
            )
            .animation(.smooth, value: progress)
            if let errorMessage {
                Text(errorMessage)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.error)

            }
            Button {
                onTapCance()
            } label: {
                Text("Cancel", bundle: .horizon)
                    .huiTypography(.buttonTextLarge)
                    .padding(5)
                    .foregroundStyle(Color.huiColors.surface.institution)
            }
        }
    }
}

#Preview {
    DownloadFileProgressView(progress: 0.3, errorMessage: "We encountered an error") {}
}
