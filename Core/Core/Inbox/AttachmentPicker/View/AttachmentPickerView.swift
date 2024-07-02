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
        VStack(alignment: .center, spacing: 0) {
            headerView
            if viewModel.fileList.isEmpty && viewModel.alreadyUploadedFileList.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitleStyled(
            VStack(spacing: 0) {
                Text(viewModel.title).font(.headline)
                if let subtitle = viewModel.subTitle, subtitle.isNotEmpty {
                    Text(subtitle).font(.subheadline)
                }
            }
        )
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
                        viewModel.didSelectFile(url: url)
                    }
                }
            case .failure:
                viewModel.showDialog(title: viewModel.fileErrorTitle, message: viewModel.fileErrorMessage)
            }
        }
        .sheet(isPresented: $viewModel.isImagePickerVisible, content: {
            ImagePickerViewController(sourceType: .photoLibrary, imageHandler: viewModel.didSelectFile)
        })
        .sheet(isPresented: $viewModel.isTakePhotoVisible, content: {
            ImagePickerViewController(sourceType: .camera, imageHandler: viewModel.didSelectFile)
                .interactiveDismissDisabled()
        })
        .sheet(isPresented: $viewModel.isAudioRecordVisible, content: {
                    AttachmentPickerAssembly.makeAudioPickerViewcontroller(router: viewModel.router, onSelect: viewModel.didSelectFile)
                        .interactiveDismissDisabled()
                })
        .confirmationAlert(
            isPresented: $viewModel.isShowingCancelDialog,
            presenting: viewModel.confirmAlert
        )
    }

    private var contentView: some View {
        List {
            ForEach(viewModel.fileList, id: \.self) { file in
                rowView(for: file)
                    .listRowSpacing(0)
                    .removeListRowSeparatorLeadingInset()
            }

            ForEach(viewModel.alreadyUploadedFileList, id: \.self) { file in
                rowView(for: file, shouldDeleteOnRemove: false)
                    .listRowSpacing(0)
                    .removeListRowSeparatorLeadingInset()
            }
        }
        .listStyle(.plain)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func rowView(for file: File, shouldDeleteOnRemove: Bool = true) -> some View {
        let fileSizeWithUnit = ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file)
        Button {
            viewModel.fileSelected.accept((controller, file))
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.displayName ?? file.localFileURL?.lastPathComponent ?? "").font(.bold16).foregroundStyle(Color.textDarkest)
                        Text(fileSizeWithUnit).font(.regular14).foregroundStyle(Color.textDark)
                        if (file.uploadError != nil) {
                            HStack(spacing: 0) {
                                Image.warningLine
                                    .resizable()
                                    .frame(
                                        width: 15 * uiScale.iconScale,
                                        height: 15 * uiScale.iconScale
                                    )
                                Text(file.uploadError!).multilineTextAlignment(.leading)
                            }
                            .font(.regular14).foregroundStyle(Color.textAlert)
                        }
                    }

                    Spacer()
                    if (file.isUploading) {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.deleteFileButtonDidTap.accept(file)
                        } label: {
                            Image.xLine
                                .resizable()
                                .frame(
                                    width: 25 * uiScale.iconScale,
                                    height: 25 * uiScale.iconScale
                                )
                        }
                    }
                }
            }
        }
        .foregroundStyle(Color.textDarkest)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(file.displayName ?? file.localFileURL?.lastPathComponent ?? "") (\(fileSizeWithUnit)"))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                if shouldDeleteOnRemove {
                    viewModel.deleteFileButtonDidTap.accept(file)
                } else {
                    viewModel.removeButtonDidTap.accept(file)
                }
            } label: {
                Image.trashLine
                    .resizable()
                    .frame(
                        width: 25 * uiScale.iconScale,
                        height: 25 * uiScale.iconScale
                    )
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            if viewModel.fileList.containsUploading {
                progressHeader
            } else if viewModel.fileList.containsError {
                errorHeader
            }
            selectionHeader
        }
        .font(.regular16)
        .foregroundStyle(Color.textDarkest)
    }

    private var selectionHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(viewModel.fileList.count + viewModel.alreadyUploadedFileList.count) Items", bundle: .core)
                Spacer()
                Button {
                    viewModel.addAttachmentButtonDidTap.accept(controller)
                } label: {
                    Image.addLine
                        .resizable()
                        .frame(
                            width: 25 * uiScale.iconScale,
                            height: 25 * uiScale.iconScale
                        )
                }
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
                .font(.bold20)
                .foregroundStyle(Color.textDarkest)
                .padding(.bottom, 6)
                .accessibilityHidden(true)

            Text("Add an attachment by tapping the plus at top right.", bundle: .core)
                .multilineTextAlignment(.center)
                .font(.regular14)
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
            } else if viewModel.alreadyUploadedFileList.contains(where: { $0.isUploading }) {
                doneButton.disabled(true)
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
