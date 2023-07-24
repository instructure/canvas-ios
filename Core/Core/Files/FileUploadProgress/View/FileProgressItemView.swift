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

struct FileProgressItemView: View {
    @ObservedObject private var viewModel: FileProgressItemViewModel

    init(viewModel: FileProgressItemViewModel) {
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
            if case .error = viewModel.state {
                Image.warningLine
                    .foregroundColor(.crimson)
            } else {
                viewModel.icon
                    .foregroundColor(.textDarkest)
            }
        }
        .padding(.top, Typography.Spacings.textCellIconTopPadding)
        .padding(.leading, Typography.Spacings.textCellIconLeadingPadding)
        .padding(.trailing, Typography.Spacings.textCellIconTrailingPadding)
        .animation(.default, value: viewModel.state)
        .accessibility(hidden: true)
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
        .foregroundColor(Color.textDarkest)
        .padding(.top, Typography.Spacings.textCellTopPadding)
        .padding(.bottom, Typography.Spacings.textCellBottomPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.accessibilityLabel)
    }

    @ViewBuilder
    private var trailingIcon: some View {
        SwiftUI.Group {
            switch viewModel.state {
            case .uploaded:
                Image.checkLine.foregroundColor(.shamrock)
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
                    .accessibility(hidden: true)
            case .uploading(let progress):
                circleProgress(progress: progress)
            case .error:
                Button(action: viewModel.remove) {
                    Image.xLine
                        .foregroundColor(.textDarkest)
                        .frame(maxHeight: .infinity)
                }
                .transition(.opacity)
                .accessibilityLabel(Text("Remove file from submission.", bundle: .core))
            case .waiting:
                circleProgress()
            case .readyForUpload:
                SwiftUI.EmptyView()
            }
        }
        .padding(.trailing, Typography.Spacings.textCellIconLeadingPadding)
        .animation(.default, value: viewModel.state)
    }

    private func circleProgress(progress: CGFloat? = nil) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(
                .determinateCircle(
                    size: 23,
                    lineWidth: 1.68)
            )
            .accentColor(Color(Brand.shared.primary))
            .frame(maxHeight: .infinity)
            .accessibility(hidden: true)
    }
}

#if DEBUG

class FileProgressView_Previews: PreviewProvider {

    @ViewBuilder
    static var previews: some View {
        FileProgressItemPreview.oneTimeDemoPreview
        FileProgressItemPreview.loopDemoPreview
        FileProgressItemPreview.staticPreviews
    }
}

#endif
