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
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject var viewModel: SubmissionCommentListCellViewModel

    @Binding var attempt: Int
    @Binding var fileID: String?

    var body: some View {
        if viewModel.author.isCurrentUser {
            VStack(alignment: .trailing, spacing: 2) {
                header
                commentView
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .paddingStyle(.horizontal, .standard)
            .padding(.top, 2)
            .padding(.bottom, 8)
        } else {
            HStack(alignment: .top, spacing: 12) {
                avatar
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
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
            date
                .accessibilityLabel(a11yLabel)
        } else {
            HStack(alignment: .center, spacing: InstUI.Styles.Padding.standard.rawValue) {
                authorName
                    .frame(maxWidth: .infinity, alignment: .leading)
                date
            }
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

    private var authorName: some View {
        Text(User.displayName(viewModel.author.name, pronouns: viewModel.author.pronouns))
            .font(.semibold16, lineHeight: .fit)
            .foregroundStyle(Color.textDarkest)
    }

    private var date: some View {
        Text(viewModel.date)
            .font(.regular12, lineHeight: .fit)
            .foregroundStyle(Color.textDark)
    }

    @ViewBuilder
    private var commentView: some View {
        switch viewModel.commentType {
        case .text(let comment, let files):
            Text(comment)
                .font(.regular14, lineHeight: .fit)
                .styleForCurrentUser(viewModel.author.isCurrentUser)
                .accessibilityHidden(true) // already included in header
                .identifier("SubmissionComments.textCell.\(viewModel.id)")
            ForEach(files, id: \.id) { file in
                Spacer().frame(height: 4)
                AttachedFileView(file: file) {
                    viewModel.didTapFileButton.send((file.id, controller))
                }
                .accessibilityLabel(
                    Text(viewModel.accessibilityLabelForCommentAttachment(file))
                )
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
        }
    }
}

private struct AttachedFileView: View {
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

private extension View {
    @ViewBuilder
    func styleForCurrentUser(_ isCurrentUser: Bool) -> some View {
        if isCurrentUser {
            self
                .foregroundStyle(Color.textLightest.variantForLightMode)
                .padding(8)
                .background(Color.red)
                .cornerRadius(16)
        } else {
            self
                .foregroundStyle(Color.textDarkest)
        }
    }
}
