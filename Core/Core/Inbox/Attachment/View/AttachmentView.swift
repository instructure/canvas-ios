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
import PhotosUI

struct AttachmentView: View {
    @ObservedObject private var viewModel: AttachmentViewModel
    @Environment(\.viewController) private var controller

    init(model: AttachmentViewModel) {
        self.viewModel = model
    }

    var body: some View {
        VStack(alignment: .center) {
            headerView
            if (viewModel.fileList.isEmpty) { emptyView } else { contentView }
            if (viewModel.isAudioRecordVisible) { AudioPicker() }
        }
        .background(Color.backgroundLightest)
        .navigationTitle("Attachments")
        .navigationBarItems(leading: cancelButton, trailing: uploadButton)
        .fileImporter(isPresented: $viewModel.isFilePickerVisible, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                urls.forEach { url in
                    viewModel.fileSelected(url: url)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .sheet(isPresented: $viewModel.isImagePickerVisible, content: {
            ImagePicker(sourceType: .photoLibrary, imageHandler: viewModel.fileSelected)
        })
        .sheet(isPresented: $viewModel.isTakePhotoVisible, content: {
            ImagePicker(sourceType: .camera, imageHandler: viewModel.fileSelected)
        })
    }

    private var contentView: some View {
        VStack {
            ForEach(viewModel.fileList, id: \.self) { file in
                rowView(for: file)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func rowView(for file: File) -> some View {
        let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file)
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(file.displayName ?? file.localFileURL?.lastPathComponent ?? "").font(.headline)
                    Text(fileSizeWithUnit).foregroundStyle(Color.textDark)
                }
                Spacer()
                if (file.isUploading) {
                    ProgressView()
                } else if (file.isUploaded) {
                    Image.checkLine
                } else if (file.uploadError != nil) {
                    Image.warningLine
                } else {
                    Button {
                        viewModel.fileRemoved(file: file)
                    } label: {
                        Image.xLine
                    }
                }
            }.padding(.horizontal, 12)
            separator
        }
        .foregroundStyle(Color.textDarkest)
    }

    private var headerView: some View {
        VStack {
            if (viewModel.fileList.contains { file in file.isUploading }) {
                progressHeader
            }
            else {
                selectionHeader
            }
        }
    }

    private var selectionHeader: some View {
        VStack {
            HStack {
                Text("\(viewModel.fileList.count) Items")
                Spacer()
                Button {
                    viewModel.addAttachmentButtonDidTap.accept(controller)
                } label: {
                    Image.addLine
                }
                .foregroundStyle(Color.textDarkest)
            }
            .padding(12)
            separator
        }
    }

    private var progressHeader: some View {
        VStack {
            let totalBytes = viewModel.fileList.map { $0.size }.reduce(0, +)
            let totalBytesWithUnit = ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)
            let sentBytes = viewModel.fileList.map { $0.bytesSent }.reduce(0, +)
            let sentBytesWithUnit = ByteCountFormatter.string(fromByteCount: Int64(sentBytes), countStyle: .file)

            VStack {
                Text("Uploading \(sentBytesWithUnit) of \(totalBytesWithUnit)")
                ProgressView(value: Float(sentBytes), total: Float(totalBytes + 1))
            }
            .padding(12)
            separator
        }
    }

    private var errorHeader: some View {
        VStack {
            VStack {
                Text("Upload Failed").font(.headline)
                Text("One or more files ailed to upload. Check your internet connection and retry to submit.")
                    .multilineTextAlignment(.center)
            }
            .padding(12)

            separator
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Image.paperclipLine.resizable().frame(width: 100, height: 100)
            Text("No attachment").font(.headline)
            Text("Add an attachment by tapping the plus at top right.")
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var uploadButton: some View {
        Button {
            viewModel.uploadButtonDidTap.accept(controller)
        } label: {
            Text("Upload", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }

    private var retryButton: some View {
        Button {
            viewModel.retryUpload()
        } label: {
            Text("Retry", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }

    private var cancelButton: some View {
        Button {
            viewModel.cancelButtonDidTap.accept(controller)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }
}

//#Preview {
//    AttachmentListView()
//}
