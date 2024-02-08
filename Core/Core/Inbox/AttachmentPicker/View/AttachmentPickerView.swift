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

public struct AttachmentPickerView: View {
    @ObservedObject private var viewModel: AttachmentPickerViewModel
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    init(model: AttachmentPickerViewModel) {
        self.viewModel = model
    }

    public var body: some View {
        VStack(alignment: .center) {
            headerView
            if (viewModel.fileList.isEmpty) { emptyView } else { ScrollView { contentView } }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
        .navigationBarItems(leading: cancelButton, trailing: actionButton)
        .fileImporter(
            isPresented: $viewModel.isFilePickerVisible,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                urls.forEach { url in
                    if url.startAccessingSecurityScopedResource() {
                        viewModel.fileSelected(url: url)
                    }
                }
            case .failure:
                viewModel.showFileErrorDialog()
            }
        }
        .sheet(isPresented: $viewModel.isImagePickerVisible, content: {
            ImagePickerViewController(sourceType: .photoLibrary, imageHandler: viewModel.fileSelected)
        })
        .sheet(isPresented: $viewModel.isTakePhotoVisible, content: {
            ImagePickerViewController(sourceType: .camera, imageHandler: viewModel.fileSelected)
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $viewModel.isAudioRecordVisible, content: {
            AttachmentPickerAssembly.makeAudioPickerViewcontroller(router: viewModel.router, onSelect: viewModel.fileSelected)
                .interactiveDismissDisabled()
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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
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
                    VStack {
                        Image.warningLine
                        Text(file.uploadError!).multilineTextAlignment(.center)
                    }
                } else {
                    Button {
                        viewModel.removeButtonDidTap.accept(file)
                    } label: {
                        Image.xLine
                    }
                }
            }
            .padding(.horizontal, 12)

            separator
        }
        .foregroundStyle(Color.textDarkest)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(file.displayName ?? file.localFileURL?.lastPathComponent ?? "") (\(fileSizeWithUnit)"))
        .accessibilityAction(named: Text("Remove attachment", bundle: .core)) {
            viewModel.removeButtonDidTap.accept(file)
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            if viewModel.fileList.containsUploading {
                progressHeader
            } else if viewModel.fileList.containsError {
                errorHeader
            } else {
                selectionHeader
            }
        }
    }

    private var selectionHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(viewModel.fileList.count) Items", bundle: .core)
                Spacer()
                Button {
                    viewModel.addAttachmentButtonDidTap.accept(controller)
                } label: {
                    Image.addLine
                        .resizable()
                        .frame(
                            width: 20 * uiScale.iconScale,
                            height: 20 * uiScale.iconScale
                        )
                }
                .foregroundStyle(Color.textDarkest)
                .accessibilityLabel(Text("Add new attachment", bundle: .core))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            separator
        }
    }

    private var progressHeader: some View {
        VStack {
            VStack {
                Text(
                    "Uploading \(viewModel.fileList.formattedBytesSent) of \(viewModel.fileList.formattedTotalSize)",
                    bundle: .core
                )
                ProgressView(
                    value: Float(viewModel.fileList.totalBytesSent),
                    total: Float(max(viewModel.fileList.totalSize, viewModel.fileList.totalBytesSent))
                )
            }
            .padding(12)
            separator
        }
    }

    private var errorHeader: some View {
        VStack {
            VStack {
                Text("Upload Failed", bundle: .core).font(.headline)
                Text("One or more files failed to upload. Check your internet connection and retry to submit.", bundle: .core)
                    .multilineTextAlignment(.center)
            }
            .padding(12)

            separator
        }
    }

    private var emptyView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image.paperclipLine
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(Color.textDarkest)
                .accessibilityHidden(true)

            Text("No attachments", bundle: .core)
                .font(.headline)
                .foregroundStyle(Color.textDarkest)
                .padding(.bottom, 6)
                .accessibilityHidden(true)

            Text("Add an attachment by tapping the plus at top right.", bundle: .core)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textDarkest)
                .accessibilityLabel(Text("No attachments, add an attachment by tapping the plus at top right.", bundle: .core))

            Spacer()
        }
        .padding(.horizontal, 12)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var actionButton: some View {
        VStack {
            if viewModel.fileList.containsError {
                retryButton
            } else if viewModel.fileList.containsUploading {
                uploadButton.disabled(true)
            } else if viewModel.fileList.isAllUploaded {
                doneButton
            } else {
                uploadButton
            }
        }
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
            viewModel.retryButtonDidTap.accept(controller)
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

    private var doneButton: some View {
        Button {
            viewModel.doneButtonDidTap.accept(controller)
        } label: {
            Text("Done", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }
}

#if DEBUG

struct AttachmentView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        AttachmentPickerAssembly.makePreview(env: env)
    }
}

#endif
