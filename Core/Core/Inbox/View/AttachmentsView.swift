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
    private let didSelectAttachment: ((File) -> Void)?

    public init(attachments: [File], didSelectAttachment: ((File) -> Void)? = nil) {
        self.attachments = attachments
        self.didSelectAttachment = didSelectAttachment
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(attachments, id: \.self) { file in
                    attachmentView(for: file)
                }
            }
        }
    }

    private func attachmentView(for file: File) -> some View {
        Button {
            didSelectAttachment?(file)
        } label: {
            if let thumbnailURL = file.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
            } else {
                VStack(spacing: 0) {
                    Image(uiImage: file.icon)
                        .padding(.bottom, 8)
                    Text(file.filename)
                        .font(.regular14)
                        .truncationMode(.middle)
                        .lineLimit(2)
                        .foregroundStyle(Color.textDark)
                }
                .padding(.all, 8)
            }
        }
        .frame(width: 104, height: 104)
        .background(Color.backgroundLight)
        .border(Color.backgroundLight)
        .cornerRadius(15)
    }
}
