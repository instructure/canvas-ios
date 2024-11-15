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

struct AssignmentSubmissionView: View {
    // MARK: - Private Properties

    @State private var importFile = false
    @State private var selectedFileURL: URL?
    @FocusState private var isFocused: Bool

    // MARK: - Dependence Properties

    @Bindable var viewModel: AssignmentDetailsViewModel
    let geometry: GeometryProxy
    var onStartTyping: (() -> Void)? = { }

    var body: some View {
        VStack(spacing: 5) {
            if viewModel.isShowSubmitButton {
                submissionTypes

                if let selectedSubmission = viewModel.selectedSubmission {
                    setSubmissionTypes(selectedSubmission)
                    submissionButton
                }
            } else {
                showSubmissionTypesButton
            }
            Rectangle()
                .fill(.clear)
                .frame(height: 150)
                .id(viewModel.keyboardObserveID)

        }
        .onChange(of: isFocused) {
            viewModel.isKeyboardVisible = isFocused
            if isFocused { onStartTyping?() }
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
                viewModel.isShowSubmitButton = true
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
                isFocused = item == .textEntry
            } label: {
                HAssignmentButton(isSelected: viewModel.selectedSubmission ==  item, assignment: item)
            }
        }
    }

    private func textEntry(geometry: GeometryProxy) -> some View {
        UITextViewWrapper(text: $viewModel.textEntry) {
            let tv = UITextView()
            tv.isScrollEnabled = false
            tv.textContainer.widthTracksTextView = true
            tv.textContainer.lineBreakMode = .byWordWrapping
            tv.font = UIFont.scaledNamedFont(.regular16)
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.widthAnchor.constraint(equalToConstant: geometry.frame(in: .global).width - (2 * 16)).isActive = true
            tv.backgroundColor = .backgroundLightest
            tv.layer.cornerRadius = 8
            tv.layer.borderWidth = 1
            tv.layer.borderColor = UIColor.disabledGray.cgColor
            return tv
        }
        .font(.regular16, lineHeight: .condensed)
        .textInputAutocapitalization(.sentences)
        .focused($isFocused)
        .foregroundColor(.textDarkest)
        .frame(minHeight: 100)
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
            Text("Submit Assignment")
                .font(.bold14)
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.backgroundInfo)
                .cornerRadius(8)
                .opacity(viewModel.isSubmitButtonDisable ? 0.3 : 1)

        }
        .disabled(viewModel.isSubmitButtonDisable)
    }

    @ViewBuilder
    private func setSubmissionTypes(_ type: AssignmentType) -> some View {
        switch type {
        case .textEntry:
            textEntry(geometry: geometry)
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
    GeometryReader { geometry in
        ScrollView {
            AssignmentSubmissionView(
                viewModel: AssignmentDetailsAssembly.makeAssignmentSubmissionViewModel(),
                geometry: geometry
            )
            .padding()
        }
    }
}
#endif
