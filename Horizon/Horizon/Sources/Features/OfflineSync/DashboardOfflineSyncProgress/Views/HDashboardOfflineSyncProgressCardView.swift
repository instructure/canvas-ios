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
    private let isError: Bool
    private let onRetry: () -> Void

    // MARK: - Init

    init(
        progress: Double,
        downloadedSize: String,
        totalSize: String,
        isError: Bool = false,
        onRetry: @escaping () -> Void = {}
    ) {
        self.progress = progress
        self.downloadedSize = downloadedSize
        self.totalSize = totalSize
        self.isError = isError
        self.onRetry = onRetry
    }

    var body: some View {
        if isError {
            errorContent
        } else {
            syncingContent
        }
    }

    // MARK: - Syncing state

    private var syncingContent: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack(spacing: .huiSpaces.space8) {
                syncIconView
                syncTitleView
            }
            downloadProgressView
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

    private var syncIconView: some View {
        Image.huiIcons.sync
            .padding(.huiSpaces.space4)
            .foregroundStyle(Color.huiColors.icon.default)
            .background(Color(hexString: "#E6EDF3"))
            .clipShape(.circle)
    }

    private var syncTitleView: some View {
        Text("Syncing offline content")
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.labelMediumBold)
    }

    @ViewBuilder
    private var downloadProgressView: some View {
        if downloadedSize.isNotEmpty, totalSize.isNotEmpty {
            Text(String(format: "Downloading %@ of %@", downloadedSize, totalSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p3)
        }
    }

    // MARK: - Error state

    private var errorContent: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            HStack(spacing: .huiSpaces.space8) {
                errorIconView
                errorTitleView
            }
            Text("Some content couldn't be downloaded.", bundle: .horizon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p3)
            HorizonUI.PrimaryButton(
                String(localized: "Retry", bundle: .horizon),
                type: .dangerOutline,
                isSmall: true,
                trailing: Image.huiIcons.restartAlt,
                action: onRetry
            )
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }

    private var errorIconView: some View {
        Image.huiIcons.error
            .foregroundStyle(Color.huiColors.icon.error)
    }

    private var errorTitleView: some View {
        Text("Sync failed", bundle: .horizon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.icon.error)
            .huiTypography(.labelMediumBold)
    }
}

#Preview("Syncing") {
    HDashboardOfflineSyncProgressCardView(
        progress: 0.3,
        downloadedSize: "12.7 MB",
        totalSize: "64 MB"
    )
    .padding()
}

#Preview("Error") {
    HDashboardOfflineSyncProgressCardView(
        progress: 0,
        downloadedSize: "",
        totalSize: "",
        isError: true,
        onRetry: {}
    )
    .padding()
}
