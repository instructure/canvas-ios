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
import HorizonUI
import Core

struct AssignmentSubmissionView: View {
    // MARK: - Private Properties

    @FocusState private var focusedInput: Bool
    @State private var isImagePickerVisible = false
    @State private var isTakePhotoVisible = false
    @State private var isOverlayUploadFileVisible = false

   private let uploadParameters: RichContentEditorUploadParameters
   private let rceID = "rceID"
    @State private var isFilePickerVisible = false

    // MARK: - Dependencies

    @Bindable private var viewModel: AssignmentDetailsViewModel
    @Binding private var isShowModuleNavBar: Bool
    private let proxy: ScrollViewProxy
    private let dismissKeyboard: Bool

    // MARK: - Init

    init(
        viewModel: AssignmentDetailsViewModel,
        isShowModuleNavBar: Binding<Bool>,
        proxy: ScrollViewProxy,
        dismissKeyboard: Bool
    ) {
        self.viewModel = viewModel
        self._isShowModuleNavBar = isShowModuleNavBar
        self.proxy = proxy
        self.uploadParameters = .init(context: .course(viewModel.courseID))
        self.dismissKeyboard = dismissKeyboard
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space24) {
            segmentView
            submissionContentView
        }
        .onChange(of: dismissKeyboard) { _, _ in
            focusedInput = false
        }
        .huiOverlay(
            title: AssignmentLocalizedKeys.uploadFile.title,
            buttons: getFileUploadButtons(),
            isPresented: $isOverlayUploadFileVisible
        )
        .fileImporter(
            isPresented: $isFilePickerVisible,
            allowedContentTypes: (viewModel.assignment?.fileExtensions ?? []).compactMap { $0.uttype }) { result in
            switch result {
            case .success(let url):
                if url.startAccessingSecurityScopedResource() {
                    addFile(url: url)
                }
                url.stopAccessingSecurityScopedResource()
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        .sheet(isPresented: $isImagePickerVisible) {
            ImagePickerViewController(sourceType: .photoLibrary, imageHandler: addFile)
        }
        .sheet(isPresented: $isTakePhotoVisible) {
            ImagePickerViewController(sourceType: .camera, imageHandler: addFile)
                .interactiveDismissDisabled()
        }
    }

    private func addFile(url: URL) {
        viewModel.addFile(url: url)
        isImagePickerVisible = false
        isTakePhotoVisible = false
        isFilePickerVisible = false
    }

    @ViewBuilder
    private var segmentView: some View {
        if viewModel.isSegmentControlVisible {
            VStack(spacing: .huiSpaces.space16) {
                Text(AssignmentLocalizedKeys.selectSubmissionType.title)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.h3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.SegmentedControl(
                    items: AssignmentSubmissionType.items,
                    icon: .checkMark,
                    iconAlignment: .leading,
                    isShowIconForAllItems: false,
                    selectedIndex: $viewModel.selectedSubmissionIndex
                )
            }
        }
    }

    @ViewBuilder
    private var submissionContentView: some View {
        switch viewModel.selectedSubmission {
        case .text:
            rceEditor
        case .externalTool:
            externalToolView
                .frame(height: 322)
        case .fileUpload:
            VStack(spacing: .huiSpaces.space8) {
                HorizonUI.FileDrop(
                    acceptedFilesType: viewModel.assignment?.allowedFileExtensions ?? ""
                ) {
                    isOverlayUploadFileVisible.toggle()
                }
                .frame(height: 190)
            }

            ForEach(viewModel.attachedFiles, id: \.self) { file in
                HorizonUI.UploadedFile(fileName: file.filename, actionType: .delete) {
                    viewModel.deleteFile(file: file)
                }
            }
        }
    }

    private var rceEditor: some View {
        InstUI.RichContentEditorCell(
            placeholder: AssignmentLocalizedKeys.addSubmissionText.title,
            html: $viewModel.htmlContent,
            uploadParameters: uploadParameters
        )
        .id(rceID)
        .focused($focusedInput)
        .onChange(of: focusedInput) { _, newValue in
            isShowModuleNavBar = !newValue
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        proxy.scrollTo(rceID, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var externalToolView: some View {
        let tools = LTITools(
            context: .course(viewModel.courseID),
            id: viewModel.assignment?.externalToolContentID,
            launchType: .assessment,
            isQuizLTI: viewModel.assignment?.isQuizLTI,
            assignmentID: viewModel.assignmentID
        )
        LTIViewRepresentable(environment: .shared, tools: tools, name: nil)
    }

    private func getFileUploadButtons() -> [HorizonUI.Overlay.ButtonAttribute] {
        guard let fileExtensions = viewModel.assignment?.fileExtensions else {  return []}
        let isIncludeMedia = fileExtensions.contains(where: { $0.isImage || $0.isVideo })
        var buttons: [HorizonUI.Overlay.ButtonAttribute]  = []

        let chooseImageButton = HorizonUI.Overlay.ButtonAttribute(
                title: AssignmentLocalizedKeys.selectMedia.title,
                icon: Image.huiIcons.image
        ) {
            isOverlayUploadFileVisible.toggle()
            isImagePickerVisible.toggle()
        }

        let takePhotoButton = HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.takeMedia.title,
            icon: Image.huiIcons.camera
        ) {
            isOverlayUploadFileVisible.toggle()
            isTakePhotoVisible.toggle()
        }

        let chooseFileButton = HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.chooseFile.title,
            icon: Image.huiIcons.image
        ) {
            isOverlayUploadFileVisible.toggle()
            isFilePickerVisible.toggle()
        }

        if isIncludeMedia {
            buttons = [chooseImageButton, takePhotoButton, chooseFileButton]
        } else {
            buttons = [chooseFileButton]
        }
        return buttons
    }
}

//#Preview {
//    AssignmentSubmissionView()
//}
