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

struct MyAssignmentSubmissionsView: View {
    // MARK: - Private Properties

    @State private var uploadedFileHeight: CGFloat = 0.0
    @State private var textHeight: CGFloat = 0.0
    @State private var selectedUploadedFile: File?
    @Environment(\.viewController) private var viewController

    // MARK: - Dependencies

    @State private var viewModel: MyAssignmentSubmissionsViewModel
    private let selectedSubmission: AssignmentSubmissionType
    private let submission: HSubmission
    private let courseId: String

    // MARK: - Init

    init(
        viewModel: MyAssignmentSubmissionsViewModel,
        selectedSubmission: AssignmentSubmissionType,
        submission: HSubmission,
        courseId: String
    ) {
        self.viewModel = viewModel
        self.selectedSubmission = selectedSubmission
        self.submission = submission
        self.courseId = courseId
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            header
            contentView
        }
    }

    private var header: some View {
        HStack {
            Image.huiIcons.checkCircleFull
                .foregroundStyle(Color.huiColors.icon.success)
                .frame(width: 24, height: 24)
            Text(selectedSubmission ==  .text
                 ? AssignmentLocalizedKeys.submissionText.title
                 : AssignmentLocalizedKeys.submissionFileUpload.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.h3)
            .foregroundColor(Color.huiColors.text.body)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedSubmission {
        case .text:
            ZStack(alignment: .leading) {
                WebView(html: submission.body ?? "")
                    .frameToFit()
                    .readingFrame { frame in
                        if textHeight == 0 {
                            textHeight = frame.size.height
                        }
                    }
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.huiColors.text.greyPrimary)
                    .frame(width: 4, height: textHeight)
            }
        case .externalTool:
            EmptyView()
        case .fileUpload:
            fileUploadView
                .onChange(of: submission.attachments) { _, _ in
                    selectedUploadedFile = submission.attachments?.first
                }
                .onAppear { selectedUploadedFile = submission.attachments?.first }
        }
    }

    private var fileUploadView: some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(submission.attachments ?? [], id: \.self) { file in
                Button {
                    selectedUploadedFile = file
                } label: {
                    uploadedFileRow(file: file)
                }
            }
            fileDetailsView(file: selectedUploadedFile)
        }
    }

    private func uploadedFileRow(file: File) -> some View {
        HorizonUI.UploadedFile(
            fileName: file.filename,
            actionType: selectedUploadedFile == file
            ? (viewModel.viewState == .loading ? .loading : .download)
            : .download,
            isSelected: selectedUploadedFile == file
        ) {
            selectedUploadedFile = file
            if viewModel.viewState == .loading {
                viewModel.cancelDownload()
            } else {
                guard let selectedUploadedFile else {
                    return
                }
                viewModel.downloadFile(viewController: viewController, file: selectedUploadedFile)
            }
        }
    }

    @ViewBuilder
    private func fileDetailsView(file: File?) -> some View {
        if let fileID = file?.id {
            FileDetailsViewRepresentable(
                isScrollTopReached: .constant(false),
                isFinishLoading: .constant(false),
                contentHeight: $uploadedFileHeight,
                context: .course(courseId),
                fileID: fileID,
                isScrollEnabled: false
            )
            .id(fileID)
            .frame(height: uploadedFileHeight)
        }
    }
}

#if DEBUG
#Preview {
    MyAssignmentSubmissionAssembly.makePreview()
}
#endif
