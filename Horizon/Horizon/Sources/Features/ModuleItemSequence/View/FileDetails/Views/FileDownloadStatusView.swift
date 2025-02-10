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
    private let onTapCancel: () -> Void

    init(
        status: FileDownloadStatus,
        fileName: String,
        onTapDownload: @escaping () -> Void,
        onTapCancel: @escaping () -> Void
    ) {
        self.status = status
        self.fileName = fileName
        self.onTapDownload = onTapDownload
        self.onTapCancel = onTapCancel
    }

    var body: some View {
        switch status {
        case .initial:
            initialView
        case .loading:
            loadingView
        case .error(let string):
            VStack(spacing: .huiSpaces.primitives.small) {
                errorView(message: string)
                initialView
            }
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
            HorizonUI.IconButton( HorizonUI.icons.close, type: .white) {
                onTapCancel()
            }
        }
    }

    private func errorView(message: String) -> some View {
        HStack(spacing: .huiSpaces.primitives.xxSmall) {
            HorizonUI.icons.error
                .foregroundStyle(Color.huiColors.icon.error)
            Text(message)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.error)
        }
    }
}

#Preview {
    FileDownloadStatusView(status: .loading, fileName: "AI.mp4") {} onTapCancel: {}
}
