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

public struct AttachmentsView: View {
    private let attachments: [File]
    private let mediaComment: MediaComment?
    private let didSelectAttachment: ((URL?, WeakViewController) -> Void)?
    @State private var isAttachmentDeleted = false
    @Environment(\.viewController) private var controller

    public init(
        attachments: [File],
        mediaComment: MediaComment?,
        didSelectAttachment: ((URL?, WeakViewController) -> Void)? = nil
    ) {
        self.attachments = attachments
        self.mediaComment = mediaComment
        self.didSelectAttachment = didSelectAttachment
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(attachments, id: \.self) { file in
                    attachmentView(for: file)
                }
                if let mediaComment {
                    mediaCommentView(media: mediaComment)
                }
            }
        }
    }

    private func attachmentView(for file: File) -> some View {
        Button {
            didSelectAttachment?(file.url, controller)
        } label: {
            VStack(spacing: 0) {
                if let thumbnailURL = file.thumbnailURL, !isAttachmentDeleted {
                    AsyncImage(url: thumbnailURL) { image in
                        image
                    } placeholder: {
                        ProgressView()
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ViewHeightKey.self, value: geometry.frame(in: .global).height)
                    })
                    .onPreferenceChange(ViewHeightKey.self) { height in
                        isAttachmentDeleted = height == 1
                    }
                } else {
                    generalAttachmentView(for: file)
                }
            }
            .padding(.all, 8)
            .frame(width: 104, height: 104)
            .background(Color.backgroundLight)
            .border(Color.backgroundLight)
            .accessibilityLabel(Text(file.filename))
        }
        .cornerRadius(5)
    }

    func generalAttachmentView(for file: File) -> some View {
        return VStack(spacing: 0) {
            Image(uiImage: file.icon)
                .padding(.bottom, 8)
            Text(file.filename)
                .font(.regular14)
                .truncationMode(.middle)
                .lineLimit(2)
                .foregroundStyle(Color.textDark)
        }
    }

   private func mediaCommentView(media: MediaComment) -> some View {
        Button {
            didSelectAttachment?(media.url, controller)
        } label: {
            VStack(spacing: 0) {
                Image(uiImage: media.mediaType == .video ? .videoLine : .audioLine)
                    .padding(.bottom, 8)
                Text(media.displayName ?? "")
                    .font(.regular14)
                    .truncationMode(.middle)
                    .lineLimit(2)
                    .foregroundStyle(Color.textDark)
            }
            .padding(.all, 8)
            .frame(width: 104, height: 104)
            .background(Color.backgroundLight)
            .border(Color.backgroundLight)
            .accessibilityLabel(Text(media.displayName ?? ""))
        }
        .cornerRadius(5)
    }
}

private struct ViewHeightKey: PreferenceKey {
    public typealias Value = CGFloat

    public static var defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

#if DEBUG

struct AttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsView(attachments: [], mediaComment: nil)
    }
}

#endif
