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

struct FileDownloadStatusView: View {
    @State private var isScaled = false

    // MARK: - Dependencies

    private let status: FileDownloadStatus
    private let fileName: String
    private let onTapDownload: () -> Void

    init(
        status: FileDownloadStatus,
        fileName: String,
        onTapDownload: @escaping () -> Void
    ) {
        self.status = status
        self.fileName = fileName
        self.onTapDownload = onTapDownload
    }

    var body: some View {
        switch status {
        case .initial:
            initialView
        case .loading:
            loadingView
        case .loaded(let filePath):
            loadedView(url: filePath)
        case .error(let string):
            errorView(message: string)
        }
    }

    private var initialView: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Download File", bundle: .horizon),
            type: .blue,
            isSmall: false,
            trailing: Image.huiIcons.download
        ) {
            onTapDownload()
        }
    }

    private var loadingView: some View {
        HStack(spacing: .huiSpaces.primitives.xSmall) {
            HorizonUI.Spinner(size: .xSmall, showBackground: true)
            Text(fileName)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
            Spacer()
        }
    }

    private func loadedView(url: URL) -> some View {
        HStack(spacing: .huiSpaces.primitives.xSmall) {
            ShareLink(item: url) {
                HorizonUI.icons.iosShare
                    .foregroundStyle(Color.huiColors.surface.institution)
            }
            .scaleEffect(isScaled ? 1 : 0.7)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isScaled)
            .onAppear {
                isScaled = true
            }

            Text(fileName)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        HStack(spacing: .huiSpaces.primitives.xSmall) {
            HorizonUI.icons.error
                .foregroundStyle(Color.huiColors.icon.error)

            Text(message)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.error)
            Spacer()
        }
    }

}

#Preview {
    FileDownloadStatusView(status: .loading, fileName: "AI Book.pdf") {}
}
