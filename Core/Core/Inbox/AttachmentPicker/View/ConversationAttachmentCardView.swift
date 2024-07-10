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

struct ConversationAttachmentsCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let files: [File]
    private let removeHandler: (_ file: File) -> Void
    private let selectHandler: (_ file: File) -> Void

    init(files: [File], selectHandler: @escaping (_ file: File) -> Void, removeHandler: @escaping (_ file: File) -> Void) {
        self.files = files
        self.removeHandler = removeHandler
        self.selectHandler = selectHandler
    }

    var body: some View {
        ForEach(files, id: \.self) { file in
            Button {
                selectHandler(file)
            } label: {
                attachmentView(for: file)
            }
            .foregroundColor(.textDarkest)
        }

    }

    private func attachmentView(for file: File) -> some View {
        let fileSize = ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file)

        return VStack {
            if file.thumbnailURL != nil { AsyncImage(url: file.thumbnailURL) }
            HStack {
                VStack(alignment: .leading) {
                    Text(file.displayName ?? file.localFileURL?.lastPathComponent ?? file.url?.lastPathComponent ?? "").font(.headline)
                    Text(fileSize)
                }
                Spacer()

                progressIndicator(for: file)

                Button {
                    removeHandler(file)
                } label: {
                    Image.xLine.foregroundStyle(Color.textDark)
                }
                .accessibilityHidden(true)
            }
            .font(.regular12)
            .foregroundColor(.textDarkest)
            .padding(12)
            .accessibilityElement(children: .combine)
            .accessibilityAction(named: Text("Remove attachment", bundle: .core)) {
                removeHandler(file)
            }
        }
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.tiara, lineWidth: 1))
        .padding(12)
    }

    @ViewBuilder
    func progressIndicator(for file: File) -> some View {
        if file.isUploading {
             ProgressView()
                .padding(.all, 8)
                .accessibilityLabel(Text("Uploading", bundle: .core))
        } else if file.isUploaded {
            Image.completeLine
                .foregroundStyle(Color.textSuccess)
                .padding(.all, 8)
                .accessibilityLabel(Text("Uploaded", bundle: .core))
        } else if file.uploadError != nil {
            Image.noLine
                .padding(.all, 8)
                .accessibilityLabel(Text("Failed to upload", bundle: .core))
        }
    }
}
