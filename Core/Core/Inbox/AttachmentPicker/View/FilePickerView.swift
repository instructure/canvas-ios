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

import SwiftUI

public struct FilePickerView: View {
    @ObservedObject private var viewModel: FilePickerViewModel
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    public init(viewModel: FilePickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            contentView
        }
        .font(.regular12)
        .foregroundColor(.textDarkest)
        .navigationTitle(viewModel.title)
        .navigationBarItems(trailing: cancelButton)
        .navigationBarGenericBackButton()
    }

    var contentView: some View {
        VStack {
            switch viewModel.state {
            case .data:
                dataContainer
            case .empty:
                emptyView
            case .error:
                errorView
            case .loading:
                ProgressView()
            }
        }
    }

    var emptyView: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(Panda.FilePicker.name, bundle: .core)
                .padding(.all, 12)

            Text("No files", bundle: .core)
                .font(.bold24)
                .padding(.vertical, 8)

            Text("This folder is empty", bundle: .core)
                .font(.regular16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var errorView: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(Panda.FilePicker.name, bundle: .core)
                .padding(.all, 12)

            Text("Some error occured", bundle: .core)
                .font(.bold24)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var dataContainer: some View {
        ScrollView {
            ForEach(viewModel.folderItems, id: \.id) { item in
                if let file = item.file {
                    fileRow(file: file)
                } else if let folder = item.folder {
                    folderRow(folder: folder)
                }
            }
        }
    }

    var cancelButton: some View {
        Button {
            viewModel.didTapCancel.accept(controller)
        } label: {
            Text("Cancel", bundle: .core)
        }
    }

    func folderItemRow(item: FolderItem) -> some View {
        return VStack(spacing: 0) {
            if let file = item.file {
                fileRow(file: file)
            } else if let folder = item.folder {
                folderRow(folder: folder)
            }
        }
    }

    func folderRow(folder: Folder) -> some View {
        return Button {
            viewModel.didTapFolder.accept((controller, folder))
        } label: {
            HStack(spacing: 0) {
                Image.folderSolid
                    .resizable()
                    .frame(
                        width: 30 * uiScale,
                        height: 30 * uiScale
                    )
                    .padding(.all, 12)

                VStack(alignment: .leading, spacing: 0) {
                    Text(folder.name)
                        .font(.bold16).foregroundStyle(Color.textDarkest)
                        .truncationMode(.middle)
                        .lineLimit(1)

                    Text("\(folder.filesCount + folder.foldersCount) \(folder.filesCount + folder.foldersCount == 1 ? "item" : "items")")
                        .font(.regular14).foregroundStyle(Color.textDark)
                }
                .padding(.horizontal, 8)

                Spacer()

                Image.arrowOpenRightLine
                    .resizable()
                    .frame(
                        width: 15 * uiScale,
                        height: 15 * uiScale
                    )
                    .padding(.all, 12)
            }
            .foregroundColor(.textDarkest)
        }
    }

    func fileRow(file: File) -> some View {
        return Button {
            viewModel.didTapFile.accept((controller, file))
        } label: {
            HStack(spacing: 0) {
                AsyncImage(url: file.thumbnailURL) { result in
                    result.image?
                        .resizable()
                        .scaledToFill()
                    }
                    .frame(
                        width: 30 * uiScale,
                        height: 30 * uiScale
                    )
                    .padding(.all, 12)

                VStack(alignment: .leading, spacing: 0) {
                    Text(file.filename)
                        .font(.bold16).foregroundStyle(Color.textDarkest)
                        .truncationMode(.middle)
                        .lineLimit(1)

                    Text(file.formattedSize)
                        .font(.regular14).foregroundStyle(Color.textDark)
                }
                .padding(.horizontal, 8)

                Spacer()

                Image.arrowOpenRightLine
                    .resizable()
                    .frame(
                        width: 15 * uiScale,
                        height: 15 * uiScale
                    )
                    .padding(.all, 12)
            }
            .foregroundColor(.textDarkest)
        }
    }
}

#if DEBUG

struct FilePickerView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        AttachmentPickerAssembly.makeFilePickerPreview(env: env)
    }
}

#endif
