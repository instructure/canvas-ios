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

struct SubmissionFileList: View {
    let submission: Submission
    let files: [File]
    @Binding var fileID: String?

    init(submission: Submission, fileID: Binding<String?>) {
        _fileID = fileID
        files = submission.attachments?.sorted(by: File.idCompare) ?? []
        self.submission = submission
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if submission.type != .online_upload || files.isEmpty {
                    EmptyPanda(.Papers, message: Text("This submission has no files.", bundle: .teacher))
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                } else if #available(iOS 14, *) {
                    LazyVStack(alignment: .leading, spacing: 0) { list }
                } else {
                    VStack(alignment: .leading, spacing: 0) { list }
                }
            }
        }
    }

    @ViewBuilder
    var list: some View {
        Divider().padding(.top, -1)
        ForEach(files, id: \.id) { (file: File) in
            let isSelected = file.id == (fileID ?? files.first?.id)
            Button(action: { if !isSelected { fileID = file.id } }, label: {
                HStack(spacing: 0) {
                    FileThumbnail(file: file)
                    Text(file.displayName ?? file.filename)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 8))
                    Spacer()
                    Image.checkSolid.size(18)
                        .opacity(isSelected ? 1 : 0)
                }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            })
                .accessibility(addTraits: isSelected ? .isSelected : [])
            Divider()
        }
    }
}

struct FileThumbnail: View {
    let file: File
    var size: CGFloat = 24

    var body: some View {
        if let url = file.thumbnailURL {
            RemoteImage(url, width: size, height: size).cornerRadius(4)
        } else if file.mimeClass == "audio" || file.contentType?.hasPrefix("audio/") == true {
            Image.audioLine.size(size)
        } else if file.mimeClass == "doc" {
            Image.documentLine.size(size)
        } else if file.mimeClass == "image" || file.contentType?.hasPrefix("image/") == true {
            Image.imageLine.size(size)
        } else if file.mimeClass == "pdf" {
            Image.pdfLine.size(size)
        } else if file.mimeClass == "video" || file.contentType?.hasPrefix("video/") == true {
            Image.videoLine.size(size)
        } else {
            Image.documentLine.size(size)
        }
    }
}
