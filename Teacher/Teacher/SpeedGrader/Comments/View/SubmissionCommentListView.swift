//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Combine

struct SubmissionCommentListView: View {
    let filePicker = FilePicker(env: .shared)
    @Binding var attempt: Int
    @Binding var fileID: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: SubmissionCommentListViewModel

    @State private var error: Text?
    @State private var isAudioRecorderVisible: Bool = false
    @State private var isVideoRecorderVisible: Bool = false
    private let avPermissionViewModel: AVPermissionViewModel = .init()

    @AccessibilityFocusState private var focusedTab: SpeedGraderPageTab?

    init(
        viewModel: SubmissionCommentListViewModel,
        attempt: Binding<Int>,
        fileID: Binding<String?>,
        focusedTab: AccessibilityFocusState<SpeedGraderPageTab?>
    ) {
        self.viewModel = viewModel
        self._attempt = attempt
        self._fileID = fileID
        self._focusedTab = focusedTab
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                switch viewModel.state {
                case .data:
                    comments
                    // Assume already loaded by parent, so skip loading & error
                case .loading, .empty, .error:
                    EmptyPanda(.NoComments, message: Text("There are no messages yet.", bundle: .teacher))
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height - 40)
                }
            }
            .background(Color.backgroundLightest)
            .scaleEffect(y: viewModel.state == .data ? -1 : 1)
            .safeAreaInset(edge: .bottom) {
                commentInputView
                    .transition(.opacity)
            }
            .sheet(isPresented: $isAudioRecorderVisible) {
                audioRecorder
            }
            .sheet(isPresented: $isVideoRecorderVisible) {
                videoRecorder
            }
        }
    }

    @ViewBuilder
    private var comments: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            error?
                .font(.semibold16).foregroundColor(.textDanger)
                .padding(16)
                .scaleEffect(y: -1)
            ForEach(viewModel.cellViewModels, id: \.id) { cellViewModel in
                SubmissionCommentListCell(
                    viewModel: cellViewModel,
                    attempt: $attempt,
                    fileID: $fileID
                )
                .scaleEffect(y: -1)
            }
        }
    }

    private var commentInputView: some View {
        CommentInputView(
            comment: viewModel.comment,
            commentLibraryButtonType: viewModel.isCommentLibraryEnabled ? .openLibrary : .hidden,
            isAttachmentButtonEnabled: true,
            contextColor: viewModel.contextColor,
            commentLibraryAction: {
                viewModel.presentCommentLibrary(sendAction: sendComment, source: controller)
            },
            addAttachmentAction: { type in
                switch type {
                case .audio: showAudioRecorder()
                case .video: showVideoRecorder()
                case .file: showFilePicker()
                }
            },
            sendAction: sendComment
        )
        .accessibilityFocused($focusedTab, equals: .comments)
    }

    func sendComment() {
        let text = viewModel.comment.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        error = nil
        viewModel.comment.value = ""
        viewModel.sendTextComment(text) { result in
            if result.isFailure {
                viewModel.comment.value = text
            }
            handleSendCommentResult(result)
        }
    }

    func showAudioRecorder() {
        avPermissionViewModel.performAfterMicrophonePermission(from: controller) {
            isAudioRecorderVisible = true
        }
    }

    var audioRecorder: some View {
        AttachmentPickerAssembly.makeAudioRecorder(router: env.router) {
            isAudioRecorderVisible = false
            sendMediaComment(type: .audio, url: $0)
        }
        .interactiveDismissDisabled()
    }

    func showVideoRecorder() {
        avPermissionViewModel.performAfterVideoPermissions(from: controller) {
            isVideoRecorderVisible = true
        }
    }

    var videoRecorder: some View {
        AttachmentPickerAssembly.makeVideoRecorder {
            isVideoRecorderVisible = false
            sendMediaComment(type: .video, url: $0)
        }
        .interactiveDismissDisabled()
    }

    func sendMediaComment(type: MediaCommentType, url: URL?) {
        guard let url else { return }

        error = nil
        viewModel.sendMediaComment(type: type, url: url) { result in
            handleSendCommentResult(result)
        }
    }

    func showFilePicker() {
        filePicker.env = env
        filePicker.pickAttachments(from: controller) {
            sendFileComment(batchID: $0)
        }
    }

    func sendFileComment(batchID: String) {
        error = nil
        viewModel.sendFileComment(batchId: batchID) { result in
            handleSendCommentResult(result)
        }
    }

    private func handleSendCommentResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let message):
            UIAccessibility.announce(message)
        case .failure(let error):
            self.error = Text(error.localizedDescription)
            UIAccessibility.announce(error.localizedDescription)
        }
    }
}
