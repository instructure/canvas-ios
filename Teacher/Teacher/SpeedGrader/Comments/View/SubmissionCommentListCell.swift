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

private enum Size {
    static let verticalSpacing: CGFloat = 2
    static let horizontalSpacing: CGFloat = 12
    static let commentBubblePadding: CGFloat = 8
    static let commentBubbleCorner: CGFloat = 16
    static let attachmentSpacing: CGFloat = 4

    enum File {
        static let width: CGFloat = 294
        static let corner: CGFloat = 24
        static let padding: CGFloat = 4
        static let icon: CGFloat = 32
        static let thumbnail: CGFloat = 56
        static let thumbnailCorner: CGFloat = 20
    }
}

struct SubmissionCommentListCell: View {
    @Environment(\.viewController) var controller

    @ObservedObject var viewModel: SubmissionCommentListCellViewModel

    @Binding var attempt: Int
    @Binding var fileID: String?

    var body: some View {
        if viewModel.author.isCurrentUser {
            VStack(alignment: .trailing, spacing: Size.verticalSpacing) {
                header
                commentView
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .paddingStyle(.horizontal, .standard)
            .padding(.top, 2)
            .padding(.bottom, 8)
        } else {
            HStack(alignment: .top, spacing: Size.horizontalSpacing) {
                avatar
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Size.verticalSpacing) {
                    header
                    commentView
                }
            }
            .paddingStyle(set: .standardCell)
        }
    }

    @ViewBuilder
    private var avatar: some View {
        let author = viewModel.author
        if author.isAnonymized {
            Avatar.Anonymous(isGroup: author.isGroup)
        } else if author.hasId {
            Button(
                action: { viewModel.didTapAvatarButton.send(controller) },
                label: { Avatar(name: author.name, url: author.avatarUrl) }
            )
        } else {
            Avatar(name: author.name, url: author.avatarUrl)
        }
    }

    @ViewBuilder
    var header: some View {
        let a11yLabel = viewModel.accessibilityLabelForHeader
        if viewModel.author.isCurrentUser {
            date(alignment: .trailing)
                .accessibilityLabel(a11yLabel)
        } else {
            authorNameAndDate
                .accessibilityElement(children: .ignore)
                .accessibilityRepresentation {
                    if viewModel.author.isAnonymized {
                        Text(a11yLabel)
                    } else if viewModel.author.hasId {
                        Button(
                            action: { viewModel.didTapAvatarButton.send(controller) },
                            label: { Text(a11yLabel) }
                        )
                        .accessibilityHint(Text("Double tap to view profile", bundle: .core))
                    } else {
                        Text(a11yLabel)
                    }
                }
        }
    }

    private var authorNameAndDate: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Size.horizontalSpacing) {
                authorName
                    .frame(maxWidth: .infinity, alignment: .leading)
                date(alignment: .trailing)
                    .layoutPriority(1)
            }
            VStack(alignment: .leading, spacing: Size.verticalSpacing) {
                authorName
                date(alignment: .leading)
            }
        }
    }

    private var authorName: some View {
        Text(User.displayName(viewModel.author.name, pronouns: viewModel.author.pronouns))
            .font(.semibold16, lineHeight: .fit)
            .foregroundStyle(Color.textDarkest)
    }

    private func date(alignment: TextAlignment) -> some View {
        Text(viewModel.date)
            .font(.regular12, lineHeight: .fit)
            .foregroundStyle(Color.textDark)
            .multilineTextAlignment(alignment)
    }

    @ViewBuilder
    private var commentView: some View {
        switch viewModel.commentType {
        case .text(let comment, let files):
            Text(comment)
                .font(.regular14, lineHeight: .fit)
                .textCommentStyle(viewModel.author.isCurrentUser, contextColor: viewModel.contextColor)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(true) // already included in header
                .identifier("SubmissionComments.textCell.\(viewModel.id)")
            ForEach(files, id: \.id) { file in
                AttachmentButton(file: file) {
                    viewModel.didTapFileButton.send((file.id, controller))
                }
                .padding(.top, Size.attachmentSpacing)
                .accessibilityLabel(viewModel.accessibilityLabelForCommentAttachment(file))
                .accessibilityHint(Text("Double tap to view file", bundle: .core))
            }
        case .audio(let url):
            AudioPlayer(url: url)
                .identifier("SubmissionComments.audioCell.\(viewModel.id)")
        case .video(let url):
            VideoPlayer(url: url)
                .cornerRadius(4)
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fill)
                .identifier("SubmissionComments.videoCell.\(viewModel.id)")
        case .attempt(let attempt, let submission):
            AttemptButton(submission: submission) {
                self.attempt = attempt
            }
            .accessibilityLabel(viewModel.accessibilityLabelForAttempt)
            .accessibilityHint(Text("Double tap to view attempt", bundle: .core))
        case .attemptWithAttachments(let attempt, let files):
            ForEach(files, id: \.id) { file in
                let isFirst = file.id == files.first?.id
                AttachmentButton(file: file) {
                    self.attempt = attempt
                    self.fileID = file.id
                }
                .padding(.top, isFirst ? 0 : Size.attachmentSpacing)
                .accessibilityLabel(viewModel.accessibilityLabelForAttemptAttachment(file))
                .accessibilityHint(Text("Double tap to view file", bundle: .core))
            }
        }
    }
}

private struct AttachmentButton: View {
    let file: File
    let action: () -> Void

    var body: some View {
        FileButton(
            icon: FileThumbnailView(
                file: file,
                thumbnailSize: Size.File.thumbnail,
                innerIconSize: Size.File.icon,
                iconBackgroundColor: .backgroundLight,
                cornerRadius: Size.File.thumbnailCorner
            ),
            title: file.displayName ?? file.filename,
            subtitle: file.size.humanReadableFileSize,
            hasSubtitleLineLimit: false,
            action: action
        )
        .identifier("SubmissionComments.fileView.\(file.id ?? "")")
    }
}

private struct AttemptButton: View {
    let submission: Submission
    let action: () -> Void

    var body: some View {
        let icon = submission.attemptIcon.map { Image(uiImage: $0) }
        FileButton(
            icon: icon?
                .scaledIcon(size: Size.File.icon, paddedTo: Size.File.thumbnail)
                .background(Color.backgroundLight.cornerRadius(Size.File.thumbnailCorner))
                .foregroundStyle(Color.textDarkest),
            title: submission.attemptTitle ?? "",
            subtitle: submission.attemptSubtitle ?? "",
            hasSubtitleLineLimit: true,
            action: action
        )
    }
}

private struct FileButton<I: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let icon: I?
    let title: String
    let subtitle: String?
    let hasSubtitleLineLimit: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Size.horizontalSpacing) {
                icon
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.semibold14)
                        .foregroundColor(.textDarkest)
                        .lineLimit(2)
                    if let subtitle {
                        Text(subtitle)
                            .font(.regular12)
                            .foregroundColor(.textDark)
                            .lineLimit(hasSubtitleLineLimit ? 1 : 0)
                    }
                }
                Spacer()
            }
            .padding(Size.File.padding)
            .frame(width: Size.File.width)
            .background(
                RoundedRectangle(cornerRadius: Size.File.corner)
                    .stroke(Color.borderMedium)
            )
        }
    }
}

private extension View {
    @ViewBuilder
    func textCommentStyle(_ isCurrentUser: Bool, contextColor: Color) -> some View {
        if isCurrentUser {
            self
                .foregroundStyle(Color.textLightest.variantForLightMode)
                .padding(Size.commentBubblePadding)
                .background(contextColor)
                .cornerRadius(Size.commentBubbleCorner)
        } else {
            self
                .foregroundStyle(Color.textDarkest)
        }
    }
}
