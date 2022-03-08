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

struct SubmissionCommentList: View {
    let assignment: Assignment
    let submission: Submission
    let filePicker = FilePicker()
    @Binding var attempt: Int?
    @Binding var fileID: String?
    @Binding var showRecorder: MediaCommentType?
    @Binding var comment: String

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject var attempts: Store<LocalUseCase<Submission>>
    @ObservedObject var comments: Store<GetSubmissionComments>
    @ObservedObject var commentLibrary: SubmissionCommentLibraryViewModel

    @State var error: Text?
    @State var showMediaOptions = false
    @State var showCommentLibrary = false

    init(
        assignment: Assignment,
        submission: Submission,
        attempts: Store<LocalUseCase<Submission>>,
        attempt: Binding<Int?>,
        fileID: Binding<String?>,
        showRecorder: Binding<MediaCommentType?>,
        enteredComment: Binding<String>,
        commentLibrary: SubmissionCommentLibraryViewModel
    ) {
        self.assignment = assignment
        self.submission = submission
        self._attempt = attempt
        self._fileID = fileID
        self._showRecorder = showRecorder
        self._comment = enteredComment
        self.attempts = attempts
        self.commentLibrary = commentLibrary
        comments = AppEnvironment.shared.subscribe(GetSubmissionComments(
            context: .course(assignment.courseID),
            assignmentID: assignment.id,
            userID: submission.userID
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    switch comments.state {
                    case .data:
                        if #available(iOS 14, *) {
                            LazyVStack(alignment: .leading, spacing: 0) { list }
                        } else {
                            VStack(alignment: .leading, spacing: 0) { list }
                        }
                    // Assume already loaded by parent, so skip loading & error
                    case .loading, .empty, .error:
                        EmptyPanda(.NoComments, message: Text("There are no messages yet."))
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height - 40)
                    }
                }
                    .background(Color.backgroundLightest)
                    .scaleEffect(y: comments.state == .data ? -1 : 1)
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
                        .onTapGesture {
                            showCommentLibrary = commentLibrary.shouldShow
                        }
                        .accessibilityAction(named: Text("Open comment library", bundle: .core)) {
                            if commentLibrary.shouldShow {
                                showCommentLibrary = true
                            } else {
                                UIAccessibility.post(notification: .screenChanged, argument: NSLocalizedString("Comment library is not available", bundle: .teacher, comment: ""))
                            }
                        }
                }
            }.sheet(isPresented: $showCommentLibrary) {
                CommentLibrarySheet(viewModel: commentLibrary, comment: $comment) {
                    sendComment()
                }
            }
        }
    }

    @ViewBuilder
    var list: some View {
        error?
            .font(.semibold16).foregroundColor(.textDanger)
            .padding(16)
            .scaleEffect(y: -1)
        ForEach(comments.all, id: \.id) { comment in
            SubmissionCommentListCell(
                assignment: assignment,
                submission: attempts.first(where: { $0.attempt == comment.attempt }) ?? submission,
                comment: comment,
                attempt: $attempt,
                fileID: $fileID
            )
                .scaleEffect(y: -1)
        }
    }

    func toolbar(containerHeight: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button(action: { showMediaOptions = true }, label: {
                Image.addSolid.size(18)
                    .foregroundColor(.textDark)
                    .padding(EdgeInsets(top: 11, leading: 11, bottom: 11, trailing: 11))
            })
                .accessibility(label: Text("Add Attachment"))
                .identifier("SubmissionComments.addMediaButton")
                .actionSheet(isPresented: $showMediaOptions) {
                    ActionSheet(title: Text("Add Attachment"), buttons: [
                        .default(Text("Record Audio"), action: recordAudio),
                        .default(Text("Record Video"), action: recordVideo),
                        .default(Text("Choose Files"), action: chooseFile),
                        .cancel(),
                    ])
                }
            CommentEditor(text: $comment, action: sendComment, containerHeight: containerHeight)
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
        }
            .background(Color.backgroundLight)
    }

    func sendComment() {
        let text = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        error = nil
        comment = ""
        CreateTextComment(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            isGroup: assignment.gradedIndividually == false,
            text: text
        ).fetch { comment, error in
            if error != nil || comment == nil {
                self.comment = text
                self.error = error.map { Text($0.localizedDescription) } ?? Text("Could not save the comment.")
            }
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
        guard let url = url else { return }
        UploadMediaComment(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            isGroup: assignment.gradedIndividually == false,
            type: type,
            url: url
        ).fetch { comment, error in
            if error != nil || comment == nil {
                self.error = error.map { Text($0.localizedDescription) } ?? Text("Could not save the comment.")
            }
        }
    }

    func chooseFile() {
        filePicker.pickAttachments(from: controller) {
            sendFileComment(batchID: $0)
        }
    }

    func sendFileComment(batchID: String) {
        UploadFileComment(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            isGroup: assignment.gradedIndividually == false,
            batchID: batchID
        ).fetch { comment, error in
            if error != nil || comment == nil {
                self.error = error.map { Text($0.localizedDescription) } ?? Text("Could not save the comment.")
            }
        }
    }

    func show(recorder: MediaCommentType?) {
        withAnimation(.default) {
            showRecorder = recorder
        }
    }
}
