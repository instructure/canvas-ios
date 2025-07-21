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
import HorizonUI
import SwiftUI

struct AttachmentView<Content: View>: View {
    @State var viewModel: AttachmentViewModel
    @ViewBuilder let content: Content

    var body: some View {
        content
            .huiOverlay(
                title: AssignmentLocalizedKeys.uploadFile.title,
                buttons: makeFileUploadButtons(),
                isPresented: $viewModel.isVisible
            )
            .fileImporter(
                isPresented: $viewModel.isFilePickerVisible,
                allowedContentTypes: viewModel.allowedContentTypes,
                onCompletion: viewModel.fileSelectionComplete
            )
            .sheet(isPresented: $viewModel.isImagePickerVisible) {
                AttachmentPickerAssembly.makeImagePicker(onSelect: viewModel.addFile)
            }
            .sheet(isPresented: $viewModel.isTakePhotoVisible) {
                AttachmentPickerAssembly.makeImageRecorder(onSelect: viewModel.addFile)
                    .interactiveDismissDisabled()
            }
    }

    private func makeFileUploadButtons() -> [HorizonUI.Overlay.ButtonAttribute] {
        viewModel.fileTypes.map { fileType in
            switch fileType {
            case .file:
                return chooseFileButton
            case .image:
                return chooseImageButton
            case .photo:
                return takePhotoButton
            }
        }
    }

    private var chooseFileButton: HorizonUI.Overlay.ButtonAttribute {
        HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.chooseFile.title,
            icon: Image.huiIcons.image,
            onAction: viewModel.chooseFile
        )
    }

    private var chooseImageButton: HorizonUI.Overlay.ButtonAttribute {
        HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.selectMedia.title,
            icon: Image.huiIcons.image,
            onAction: viewModel.chooseImage
        )
    }

    private var takePhotoButton: HorizonUI.Overlay.ButtonAttribute {
        HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.takeMedia.title,
            icon: Image.huiIcons.camera,
            onAction: viewModel.choosePhoto
        )
    }
}
