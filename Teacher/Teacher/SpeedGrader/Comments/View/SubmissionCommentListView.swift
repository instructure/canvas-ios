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
    @Binding var showRecorder: MediaCommentType?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: SubmissionCommentListViewModel

    @State var error: Text?

    @AccessibilityFocusState private var focusedTab: SubmissionGraderView.GraderTab?

    init(
        viewModel: SubmissionCommentListViewModel,
        attempt: Binding<Int>,
        fileID: Binding<String?>,
        showRecorder: Binding<MediaCommentType?>,
        focusedTab: AccessibilityFocusState<SubmissionGraderView.GraderTab?>
    ) {
        self.viewModel = viewModel
        self._attempt = attempt
        self._fileID = fileID
        self._showRecorder = showRecorder
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
                switch showRecorder {
                case .audio:
                    InstUI.Divider()
                    AudioRecorder {
                        show(recorder: nil)
                        sendMediaComment(type: .audio, url: $0)
                    }
                    .background(Color.backgroundLight)
                    .frame(height: 240)
                    .transition(.move(edge: .bottom))
                case .video:
                    InstUI.Divider()
                    VideoRecorder(camera: .front) {
                        show(recorder: nil)
                        sendMediaComment(type: .video, url: $0)
                    }
                    .background(Color.backgroundLight)
                    .frame(height: geometry.size.height)
                    .transition(.move(edge: .bottom))
                case nil:
                    toolbar
                        .transition(.opacity)
                }
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

    private var toolbar: some View {
        CommentInputView(
            comment: viewModel.comment,
            commentLibraryButtonType: viewModel.isCommentLibraryAvailable ? .openLibrary : .hidden,
            isAttachmentButtonEnabled: true,
            contextColor: viewModel.contextColor,
            commentLibraryAction: {
                viewModel.presentCommentLibrary(sendAction: sendComment, source: controller)
            },
            addAttachmentAction: { type in
                switch type {
                case .audio: recordAudio()
                case .video: recordVideo()
                case .file: chooseFile()
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

    func recordAudio() {
        AudioRecorder.requestPermission { allowed in
            guard allowed else {
                controller.value.showPermissionError(.microphone)
                return
            }
            show(recorder: .audio)
        }
    }

    func recordVideo() {
        VideoRecorder.requestPermission { allowed in
            guard allowed else {
                controller.value.showPermissionError(.camera)
                return
            }
            AudioRecorder.requestPermission { allowed in
                guard allowed else {
                    controller.value.showPermissionError(.microphone)
                    return
                }
                show(recorder: .video)
            }
        }
    }

    func sendMediaComment(type: MediaCommentType, url: URL?) {
        guard let url else { return }

        error = nil
        viewModel.sendMediaComment(type: type, url: url) { result in
            handleSendCommentResult(result)
        }
    }

    func chooseFile() {
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

    func show(recorder: MediaCommentType?) {
        withAnimation(.default) {
            showRecorder = recorder
        }
    }
}
