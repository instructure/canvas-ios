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
    @Binding var comment: String

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: SubmissionCommentListViewModel
    @ObservedObject var commentLibrary: SubmissionCommentLibraryViewModel

    @State var error: Text?
    @State var showMediaOptions = false
    @State var showCommentLibrary = false

    @AccessibilityFocusState private var focusedTab: SubmissionGraderView.GraderTab?

    init(
        viewModel: SubmissionCommentListViewModel,
        attempt: Binding<Int>,
        fileID: Binding<String?>,
        showRecorder: Binding<MediaCommentType?>,
        enteredComment: Binding<String>,
        commentLibrary: SubmissionCommentLibraryViewModel,
        focusedTab: AccessibilityFocusState<SubmissionGraderView.GraderTab?>
    ) {
        _viewModel = ObservedObject(wrappedValue: viewModel)

        self._attempt = attempt
        self._fileID = fileID
        self._showRecorder = showRecorder
        self._comment = enteredComment
        self.commentLibrary = commentLibrary
        self._focusedTab = focusedTab

    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    switch viewModel.state {
                    case .data(let comments):
                        LazyVStack(alignment: .leading, spacing: 0) { list(comments) }
                    // Assume already loaded by parent, so skip loading & error
                    case .loading, .empty, .error:
                        EmptyPanda(.NoComments, message: Text("There are no messages yet.", bundle: .teacher))
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height - 40)
                    }
                }
                    .background(Color.backgroundLightest)
                    .scaleEffect(y: viewModel.state.isData ? -1 : 1)
                Divider()
                switch showRecorder {
                case .audio:
                    AudioRecorder {
                        show(recorder: nil)
                        sendMediaComment(type: .audio, url: $0)
                    }
                        .background(Color.backgroundLight)
                        .frame(height: 240)
                        .transition(.move(edge: .bottom))
                case .video:
                    VideoRecorder(camera: .front) {
                        show(recorder: nil)
                        sendMediaComment(type: .video, url: $0)
                    }
                        .background(Color.backgroundLight)
                        .frame(height: geometry.size.height)
                        .transition(.move(edge: .bottom))
                case nil:
                    toolbar(containerHeight: geometry.size.height)
                        .transition(.opacity)
                }
            }.sheet(isPresented: $showCommentLibrary) {
                CommentLibrarySheet(viewModel: commentLibrary, comment: $comment) {
                    sendComment()
                }
            }
        }
    }

    @ViewBuilder
    func list(_ comments: [SubmissionComment]) -> some View {
        error?
            .font(.semibold16).foregroundColor(.textDanger)
            .padding(16)
            .scaleEffect(y: -1)
        ForEach(comments, id: \.id) { comment in
            SubmissionCommentListCell(
                viewModel: viewModel.cellConfig(with: comment),
                attempt: $attempt,
                fileID: $fileID
            )
                .scaleEffect(y: -1)
        }
    }

    func toolbar(containerHeight: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button(action: { showMediaOptions = true }, label: {
                Image.paperclipLine.size(18)
                    .foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 11, leading: 11, bottom: 11, trailing: 11))
            })
                .accessibility(label: Text("Add Attachment", bundle: .teacher))
                .identifier("SubmissionComments.addMediaButton")
                .actionSheet(isPresented: $showMediaOptions) {
                    ActionSheet(title: Text("Add Attachment", bundle: .teacher), buttons: [
                        .default(Text("Record Audio", bundle: .teacher), action: recordAudio),
                        .default(Text("Record Video", bundle: .teacher), action: recordVideo),
                        .default(Text("Choose Files", bundle: .teacher), action: chooseFile),
                        .cancel()
                    ])
                }
            CommentEditorView(
                text: $comment,
                shouldShowCommentLibrary: commentLibrary.shouldShow,
                showCommentLibrary: $showCommentLibrary,
                action: sendComment,
                containerHeight: containerHeight
            )
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
                .accessibilityFocused($focusedTab, equals: .comments)
        }
            .background(Color.backgroundLight)
    }

    func sendComment() {
        let text = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        error = nil
        comment = ""
        viewModel.sendTextComment(text) { result in
            if result.isFailure {
                self.comment = text
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
