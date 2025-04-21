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

struct SubmissionCommentListCell: View {
    let assignment: Assignment
    let submission: Submission
    let comment: SubmissionComment

    @Binding var attempt: Int
    @Binding var fileID: String?

    @Environment(\.appEnvironment.currentSession?.userID) var currentUserID
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        let isAuthor = comment.authorID == currentUserID
        VStack(alignment: isAuthor ? .trailing : .leading, spacing: 0) {
            header
            if let attempt = comment.attempt {
                if submission.type == .online_upload {
                    Spacer().frame(height: 8)
                    ForEach(submission.attachments?.sorted(by: File.idCompare) ?? [], id: \.id) { file in
                        Spacer().frame(height: 4)
                        SubmissionCommentFile(file: file) {
                            self.attempt = attempt
                            self.fileID = file.id
                        }
                        .accessibilityLabel(
                            Text(comment.accessibilityLabelForAttemptAttachment(file, submission: submission))
                        )
                        .accessibilityHint(Text("Double tap to view file", bundle: .core))
                    }
                } else {
                    Spacer().frame(height: 12)
                    SubmissionAttempt(submission: submission) {
                        self.attempt = attempt
                    }
                    .accessibilityLabel(
                        Text(comment.accessibilityLabelForAttempt(submission: submission))
                    )
                    .accessibilityHint(Text("Double tap to view attempt", bundle: .core))
                }
            } else if comment.mediaType == .some(.audio), let url = comment.mediaLocalOrRemoteURL {
                Spacer().frame(height: 12)
                AudioPlayer(url: url)
                    .identifier("SubmissionComments.audioCell.\(comment.id)")
            } else if comment.mediaType == .some(.video), let url = comment.mediaLocalOrRemoteURL {
                Spacer().frame(height: 12)
                VideoPlayer(url: url)
                    .cornerRadius(4)
                    .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fill)
                    .identifier("SubmissionComments.videoCell.\(comment.id)")
            } else {
                Spacer().frame(height: 4)
                Text(comment.comment)
                    .font(.regular14).foregroundColor(isAuthor ? .textLightest.variantForLightMode : .textDarkest)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(CommentBackground()
                        .fill(isAuthor ? Color.backgroundInfo : Color.backgroundLight)
                        .scaleEffect(x: isAuthor ? -1: 1)
                    )
                    .accessibilityHidden(true) // already included in header
                    .identifier("SubmissionComments.textCell.\(comment.id)")
                ForEach(comment.attachments?.sorted(by: File.idCompare) ?? [], id: \.id) { file in
                    Spacer().frame(height: 4)
                    SubmissionCommentFile(file: file) {
                        guard let id = file.id else { return }
                        env.router.route(
                            to: "/files/\(id)",
                            from: controller,
                            options: .modal(embedInNav: true, addDoneButton: true)
                        )
                    }
                    .accessibilityLabel(
                        Text(comment.accessibilityLabelForCommentAttachment(file))
                    )
                    .accessibilityHint(Text("Double tap to view file", bundle: .core))
                }
            }
        }
            .padding(16)
    }

    var header: some View {
        HStack(spacing: 12) {
            if comment.authorID == currentUserID {
                Spacer()
                VStack(alignment: .trailing, spacing: 0, content: headerText)
                    .multilineTextAlignment(.trailing)
                avatar
            } else {
                avatar
                VStack(alignment: .leading, spacing: 0, content: headerText)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityRepresentation {
            if assignment.anonymizeStudents && comment.authorID != currentUserID {
                Text(comment.accessibilityLabelForHeader)
            } else if let id = comment.authorID {
                Button(
                    action: { avatarButtonAction(authorId: id) },
                    label: { Text(comment.accessibilityLabelForHeader) }
                )
                .accessibilityHint(Text("Double tap to view profile", bundle: .core))
            } else {
                Text(comment.accessibilityLabelForHeader)
            }
        }
    }

    @ViewBuilder var avatar: some View {
        if assignment.anonymizeStudents && comment.authorID != currentUserID {
            (submission.groupID != nil ? Image.groupLine : Image.userLine)
                .foregroundColor(.textDark)
                .frame(width: 40, height: 40)
                .cornerRadius(20)
                .overlay(Circle()
                    .stroke(Color.borderMedium, lineWidth: 1)
                )
        } else if let id = comment.authorID {
            Button(
                action: { avatarButtonAction(authorId: id) },
                label: { Avatar(name: comment.authorName, url: comment.authorAvatarURL) }
            )
        } else {
            Avatar(name: comment.authorName, url: comment.authorAvatarURL)
        }
    }

    private func avatarButtonAction(authorId: String) {
        env.router.route(
            to: "/courses/\(assignment.courseID)/users/\(authorId)",
            userInfo: ["navigatorOptions": ["modal": true]], // fix nav style
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    @ViewBuilder func headerText() -> some View {
        Text(User.displayName(comment.authorName, pronouns: comment.authorPronouns))
            .font(.semibold14).foregroundColor(.textDarkest)
        Text(comment.createdAtLocalizedString)
            .font(.medium12).foregroundColor(.textDark)
    }
}

struct SubmissionCommentFile: View {
    let file: File
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .top, spacing: 6) {
                FileThumbnail(file: file, size: 18)
                VStack(alignment: .leading, spacing: 0) {
                    Text(file.displayName ?? file.filename)
                        .font(.semibold14).foregroundColor(.textDarkest)
                        .multilineTextAlignment(.leading)
                    Text(file.size.humanReadableFileSize)
                        .font(.medium12).foregroundColor(.textDark)
                }
                Spacer()
            }
                .padding(.horizontal, 8).padding(.vertical, 6)
                .frame(width: 300)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium))
        })
            .identifier("SubmissionComments.fileView.\(file.id ?? "")")
    }
}

struct SubmissionAttempt: View {
    let submission: Submission
    let action: () -> Void

    var icon: Image? {
        submission.attemptIcon.map { Image(uiImage: $0) }
    }

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .top, spacing: 6) {
                icon?.size(18).foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 0) {
                    Text(submission.attemptTitle ?? "")
                        .font(.semibold14).foregroundColor(.textDarkest)
                    Text(submission.attemptSubtitle ?? "")
                        .font(.medium12).foregroundColor(.textDark)
                        .lineLimit(1)
                }
                Spacer()
            }
                .padding(.horizontal, 8).padding(.vertical, 6)
                .frame(width: 300)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium))
        })
    }
}

struct CommentBackground: Shape {
    func path(in rect: CGRect) -> Path { Path { path in
        let r: CGFloat = 12
        path.move(to: CGPoint(x: 0, y: -5))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY - r))
        path.addArc(tangent1End: CGPoint(x: 0, y: rect.maxY), tangent2End: CGPoint(x: r, y: rect.maxY), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY - r), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX, y: r))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: 0), tangent2End: CGPoint(x: rect.maxX - r, y: 0), radius: r)
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addRelativeArc(center: CGPoint(x: 20, y: -24), radius: 24, startAngle: .radians(0.5 * .pi), delta: .degrees(56))
    } }
}
