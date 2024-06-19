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

struct ConversationAttachmentCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let file: File
    private let removeHandler: () -> Void
    private var fileSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file)
    }

    init(file: File, removeHandler: @escaping () -> Void) {
        self.file = file
        self.removeHandler = removeHandler
    }

    var body: some View {
        VStack {
            if file.isUploading { ProgressView(value: Float(file.bytesSent), total: Float(file.size)).padding(.all, 12) }
            else if file.thumbnailURL != nil { AsyncImage(url: file.thumbnailURL) }
            HStack {
                VStack(alignment: .leading) {
                    Text(file.displayName ?? file.localFileURL?.lastPathComponent ?? file.url?.lastPathComponent ?? "").font(.headline)
                    Text(fileSize)
                }
                Spacer()
                Button {
                    removeHandler()
                } label: {
                    Image.xLine.foregroundStyle(Color.textDark)
                }
            }
            .font(.regular12)
            .foregroundColor(.textDarkest)
            .padding(12)
        }
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.tiara, lineWidth: 1))
        .padding(12)
    }
}
