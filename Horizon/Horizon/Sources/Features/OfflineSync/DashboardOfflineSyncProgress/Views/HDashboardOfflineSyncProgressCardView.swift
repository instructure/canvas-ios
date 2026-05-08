//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct HDashboardOfflineSyncProgressCardView: View {
    // MARK: - Properties

    private let progress: Double
    private let downloadedSize: String
    private let totalSize: String

    // MARK: - Init

    init(
        progress: Double,
        downloadedSize: String,
        totalSize: String
    ) {
        self.progress = progress
        self.downloadedSize = downloadedSize
        self.totalSize = totalSize
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack(spacing: .huiSpaces.space8) {
                iconView
                titleView
            }
            progressView
            HorizonUI.ProgressBar(
                    progress: progress,
                    progressColor: Color.huiColors.primitives.blue82,
                    size: .small,
                    numberPosition: .hidden,
                    backgroundColor: Color.huiColors.primitives.blue12
                )
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }

    private var iconView: some View {
        Image.huiIcons.sync
            .padding(.huiSpaces.space4)
            .foregroundStyle(Color.huiColors.icon.default)
            .background(Color(hexString: "#E6EDF3"))
            .clipShape(.circle)
    }

    private var titleView: some View {
        Text("Syncing offline content")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.labelMediumBold)
    }

    @ViewBuilder
    private var progressView: some View {
        if !downloadedSize.isEmpty && !totalSize.isEmpty {
            Text(String(format: "Downloading %@ of %@", downloadedSize, totalSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p3)
        }
    }
}

#Preview {
    HDashboardOfflineSyncProgressCardView(
        progress: 0.3,
        downloadedSize: "12.7 MB",
        totalSize: "64 MB"
    )
    .padding()
}
