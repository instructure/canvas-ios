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
        VStack(alignment: .leading) {
            headerView
            if (viewModel.selectedFileUrls.isEmpty) { emptyView } else { contentView }
            if (viewModel.isAudioRecordVisible) { AudioPicker() }
        }
        .background(Color.backgroundLightest)
        .navigationTitle("Attachments")
        .navigationBarItems(leading: cancelButton, trailing: uploadButton)
        .fileImporter(isPresented: $viewModel.isFilePickerVisible, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                viewModel.selectedFileUrls.append(contentsOf: urls)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .sheet(isPresented: $viewModel.isImagePickerVisible, content: {
            ImagePicker(sourceType: .photoLibrary, imageHandler: viewModel.add)
        })
        .sheet(isPresented: $viewModel.isTakePhotoVisible, content: {
            ImagePicker(sourceType: .camera, imageHandler: viewModel.add)
        })
    }

    var contentView: some View {
        ForEach(viewModel.selectedFileUrls, id: \.absoluteString) { url in
            Text(url.absoluteString).padding()
        }
    }

    var headerView: some View {
        HStack {
            Text("\(viewModel.selectedFileUrls.count) Items")
            Spacer()
            Button {
                viewModel.addAttachmentButtonDidTap.accept(controller)
            } label: {
                Image.addLine
            }
        }
        .padding(12)
    }

    var emptyView: some View {
        VStack {
            Spacer()
            Image.paperclipLine
            Text("No attachment")
            Text("Add an attachment by tapping the plus at top right.")
            Spacer()
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
