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

import Core
import SwiftUI

struct AttachmentView<Content: View>: View {

    @State var viewModel: AttachmentViewModel
    @ViewBuilder let content: Content

    var body: some View {
        content
            .fileImporter(
                isPresented: $viewModel.isFilePickerVisible,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    viewModel.addFiles(urls: urls)
                case .failure:
                    break
                }
            }
            .sheet(isPresented: $viewModel.isImagePickerVisible) {
                ImagePickerViewController(
                    sourceType: .photoLibrary,
                    imageHandler: viewModel.addFile
                )
            }
            .sheet(isPresented: $viewModel.isTakePhotoVisible) {
                ImagePickerViewController(
                    sourceType: .camera,
                    imageHandler: viewModel.addFile
                )
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $viewModel.isAudioRecordVisible) {
                AttachmentPickerAssembly.makeAudioPickerViewcontroller(
                    router: viewModel.router,
                    onSelect: viewModel.addFile
                )
                .interactiveDismissDisabled()
            }
    }
}
