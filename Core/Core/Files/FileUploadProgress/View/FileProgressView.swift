//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct FileProgressView: View {
    @ObservedObject private var viewModel: FileProgressViewModel

    init(viewModel: FileProgressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            leadingIcon
            fileInfo
            Spacer()
            trailingIcon
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.backgroundLightest)
    }

    private var leadingIcon: some View {
        SwiftUI.Group {
            if viewModel.showErrorIcon {
                Image.warningLine
                    .foregroundColor(.crimson)
                    .transition(.asymmetric(insertion: .slide, removal: .opacity))
            } else {
                viewModel.icon
            }
        }
        .padding(.top, Typography.Spacings.textCellIconTopPadding)
        .padding(.leading, Typography.Spacings.textCellIconLeadingPadding)
        .padding(.trailing, Typography.Spacings.textCellIconTrailingPadding)
        .animation(.default)
    }

    private var fileInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.fileName)
                .style(.textCellTitle)
                .truncationMode(.middle)
                .lineLimit(1)
            Text(viewModel.size)
                .style(.textCellSupportingText)
        }
        .padding(.top, Typography.Spacings.textCellTopPadding)
        .padding(.bottom, Typography.Spacings.textCellBottomPadding)
    }

    @ViewBuilder
    private var trailingIcon: some View {
        let placeholder = Color.clear.frame(width: 23)
        SwiftUI.Group {
            if !viewModel.showErrorIcon {
                if viewModel.isCompleted {
                    Image.checkLine.foregroundColor(.shamrock)
                        .frame(maxHeight: .infinity)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else if viewModel.isUploading {
                    CircleProgress(color: .electric, progress: viewModel.progress, size: 23, thickness: 1.2)
                        .frame(maxHeight: .infinity)
                } else {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .padding(.trailing, Typography.Spacings.textCellIconLeadingPadding)
        .animation(.default)
    }
}

#if DEBUG

class FileProgressView_Previews: PreviewProvider {

    @ViewBuilder
    static var previews: some View {
        FileProgressViewPreview.oneTimeDemoPreview
        FileProgressViewPreview.loopDemoPreview
        FileProgressViewPreview.staticPreviews
    }
}

#endif
