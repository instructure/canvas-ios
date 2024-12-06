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
import Core
import UniformTypeIdentifiers

struct AssignmentSubmissionView: View {
    // MARK: - Private Properties

    @Environment(\.viewController) private var viewController
    @State private var importFile = false
    @State private var selectedFileURL: URL?

    // MARK: - Dependence Properties

    @Bindable var viewModel: AssignmentDetailsViewModel

    var body: some View {
        VStack(spacing: 5) {
            if viewModel.isSubmitButtonVisible {
                submissionTypes
                if let selectedSubmission = viewModel.selectedSubmission {
                    setSubmissionTypes(selectedSubmission)
                    submissionButton
                }
            } else {
                showSubmissionTypesButton
            }
        }
        .fileImporter(
            isPresented: $importFile,
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
}

// MARK: - Custom Views
extension AssignmentSubmissionView {

    private var showSubmissionTypesButton: some View {
        Button {
            withAnimation {
                viewModel.isSubmitButtonVisible = true
            }
        } label: {
            Text(viewModel.assignment?.submitButtonTitle ?? "")
                .font(.regular14)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.borderMedium.opacity(0.2))
                .clipShape(.rect(cornerRadius: 8))
        }
    }

    private var submissionTypes: some View {
        ForEach(viewModel.assignment?.assignmentTypes ?? [], id: \.self) { item in
            Button {
                viewModel.selectedSubmission = item
            } label: {
                HAssignmentButton(isSelected: viewModel.selectedSubmission ==  item, assignment: item)
            }
        }
    }

    private var pickupFileView: some View {
        VStack(spacing: .zero) {
            AttachedFilesView(files: viewModel.attachments) { deletedFile in
                viewModel.submissionEvents.send(.deleteFile(file: deletedFile))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            Spacer()
            InstUI.Divider()
            Button {
                importFile.toggle()
            } label: {
                Image.addDocumentLine
                    .padding(5)
                    .padding(.bottom, 5)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.disabledGray, lineWidth: 1)
        }
    }

    private var submissionButton: some View {
        Button {
            let selectedSubmission = viewModel.selectedSubmission ?? .textEntry
            switch selectedSubmission {
            case .textEntry:
                viewModel.submissionEvents.send(.onTextEntry)
            case .uploadFile:
                viewModel.submissionEvents.send(.sendFileTapped)
            }
        } label: {
            Text("Submit Assignment", bundle: .horizon)
                .font(.bold14)
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.backgroundInfo)
                .cornerRadius(8)
                .opacity(viewModel.isSubmitButtonDisabled ? 0.3 : 1)
        }
        .disabled(viewModel.isSubmitButtonDisabled)
    }

    private var textEntryView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            WebView(html: viewModel.htmlContent)
                .frameToFit()
                .padding(.horizontal, -16)
                .background(Color.backgroundLight)
            textEntryButton
        }
        .padding(5)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.backgroundInfo, lineWidth: 1)
        }
    }

    private var textEntryButton: some View {
        Button {
            viewModel.presentRichContentEditor(controller: viewController)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "square.and.pencil")
                let editText = String(localized: "Edit", bundle: .horizon)
                let addText = String(localized: "Add your text", bundle: .horizon)
                Text(viewModel.htmlContent.isEmpty ? addText : editText)
                    .font(.regular14)
            }
            .foregroundStyle(Color.textDarkest)
            .padding(2)
            .frame(maxWidth: .infinity)
            .frame(height: 35)
            .background(Color.borderMedium.opacity(0.2))
            .clipShape(.rect(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private func setSubmissionTypes(_ type: AssignmentType) -> some View {
        switch type {
        case .textEntry:
            textEntryView
        case .uploadFile:
            pickupFileView
        }
    }
}

// MARK: - Events
extension AssignmentSubmissionView {
    enum Events {
        case onTextEntry
        case uploadFile(url: URL)
        case sendFileTapped
        case deleteFile(file: File)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AssignmentSubmissionView(viewModel: AssignmentDetailsAssembly.makeAssignmentSubmissionViewModel())
            .padding()

    }
}
#endif
