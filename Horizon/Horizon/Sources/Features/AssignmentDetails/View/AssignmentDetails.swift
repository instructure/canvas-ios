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

struct AssignmentDetails: View {

    // MARK: - Dependencies
    @State private var viewModel: AssignmentDetailsViewModel
    @Binding private var isShowHeader: Bool
    @FocusState private var focusedInput: Bool
    @State private var isShowFileImporter = false
    @State private var isPresentOverlayUploadFile = false

    init(
        viewModel: AssignmentDetailsViewModel,
        isShowHeader: Binding<Bool> = .constant(false)
    ) {
        self.viewModel = viewModel
        self._isShowHeader = isShowHeader
    }

    var body: some View {
        ScrollViewReader { _ in
            ScrollView(showsIndicators: false) {
                VStack(spacing: .huiSpaces.space24) {
                    introView
                        .id(viewModel.courseID)
                    if viewModel.didSubmitBefore {
                        MyAssignmentSubmissionAssembly.makeView(
                            selectedSubmission: viewModel.selectedSubmission,
                            submission: viewModel.submission,
                            courseId: viewModel.courseID
                        )
                        .id(viewModel.submission.id)
                    } else {
                        segmentView
                        submissionContentView
                        submitButton
                    }
                }
                .padding(.huiSpaces.space24)
            }

        }
        .overlay { if viewModel.isLoaderVisible { HorizonUI.Spinner(size: .small, showBackground: true) } }
        .huiOverlay(
            title: "Upload File",
            buttons: getFileUploadButtons(),
            isPresented: $isPresentOverlayUploadFile
        )
        .fileImporter(
            isPresented: $isShowFileImporter,
            allowedContentTypes: (viewModel.assignment?.fileExtensions ?? [])
                .compactMap { $0.uttype }) { result in
                    switch result {
                    case .success(let success):
                        self.viewModel.submissionEvents.send(.uploadFile(url: success))
                    case .failure(let failure):
                        debugPrint(failure)
                    }
                }
    }

    @ViewBuilder
    private var introView: some View {
        if let details = viewModel.assignment?.details {
            WebView(html: details)
                .frameToFit()
                .padding(.horizontal, -16)
        }
    }

    @ViewBuilder
    private var segmentView: some View {
        if viewModel.isSegmentControlVisible {
            VStack(spacing: .huiSpaces.space16) {
                Text("Select a Submission Type", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.h3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizonUI.SegmentedControl(
                    items: AssignmentSubmissionType.items(),
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
            Rectangle()
                .fill(.red)
                .frame(height: 300)
        case .fileUpload:
            VStack(spacing: .huiSpaces.space8) {
                HorizonUI.FileDrop(
                    acceptedFilesType: viewModel.assignment?.allowedFileExtensions ?? ""
                ) {
                    isPresentOverlayUploadFile.toggle()
                }
                .frame(height: 190)
            }

            ForEach(viewModel.attachedFiles, id: \.self) { file in
                HorizonUI.UploadedFile(fileName: file.filename, actionType: .delete) {
                    viewModel.submissionEvents.send(.deleteFile(file: file))
                }
            }
        }
    }

    private var rceEditor: some View {
        TextEditor(text: $viewModel.htmlContent)
            .focused($focusedInput)
            .frame(height: 320)
            .padding(.huiSpaces.space4)
            .huiBorder(level: .level1, color: Color.huiColors.surface.institution, radius: 10)
    }

    private var submitButton: some View {
        HStack {
            Spacer()
            HorizonUI.PrimaryButton(String(localized: "Submit Assignment", bundle: .horizon)) {
                viewModel.submitTextEntry()
            }
            .disableWithOpacity(viewModel.htmlContent.isEmpty)
        }
    }

    private func getFileUploadButtons() -> [HorizonUI.Overlay.ButtonAttribute] {
        guard let fileExtensions = viewModel.assignment?.fileExtensions else {  return []}

        var buttons: [HorizonUI.Overlay.ButtonAttribute]  = []

        if fileExtensions.contains(where: { $0.isImage || $0.isVideo }) {
               buttons.append(.init(title: "Choose Photo or Video", icon: Image.huiIcons.image) {
                   print("Choose Photo or Video")
               })
           }

           if fileExtensions.contains(where: { $0.isAny }) {
               buttons.append(.init(title: "Choose File", icon: Image.huiIcons.folder) {
                   print("Choose File")
                   isPresentOverlayUploadFile.toggle()
                   isShowFileImporter.toggle()
               })
           }

        return buttons
    }
}

#if DEBUG
#Preview {
    AssignmentDetailsAssembly.makePreview()
}
#endif
