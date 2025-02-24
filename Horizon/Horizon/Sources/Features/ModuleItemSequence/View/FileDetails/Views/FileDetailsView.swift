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
import Core
import HorizonUI

struct FileDetailsView: View {
    // MARK: - Private Properties

    @State private var didFinishRenderingPreview: Bool = false
    @Environment(\.viewController) private var viewController
    @State var isShowHeader: Bool = true

    // MARK: - Dependencies

    @State private var viewModel: FileDetailsViewModel
    private let context: Context?
    private let fileID: String
    private let fileName: String

    init(
        viewModel: FileDetailsViewModel,
        context: Context?,
        fileID: String,
        fileName: String
    ) {
        self.context = context
        self.fileID = fileID
        self.fileName = fileName
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if isShowHeader {
                FileDownloadStatusView(status: viewModel.viewState, fileName: fileName) {
                    viewModel.downloadFile(viewController: viewController, fileID: fileID)
                } onTapCancel: {
                    viewModel.cancelDownload()
                }
                .padding(.vertical, .huiSpaces.space12)
                .padding(.horizontal, .huiSpaces.space24)
                .hidden(!didFinishRenderingPreview)
            }
            FileDetailsViewRepresentable(
                isScrollTopReached: $isShowHeader,
                isFinishLoading: $didFinishRenderingPreview,
                context: context,
                fileID: fileID
            )
        }
        .animation(.smooth, value: viewModel.viewState)
        .animation(.smooth, value: [isShowHeader, didFinishRenderingPreview])
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
    }
}
#if DEBUG
#Preview {
    FileDetailsAssembly.makePreview()
}
#endif
