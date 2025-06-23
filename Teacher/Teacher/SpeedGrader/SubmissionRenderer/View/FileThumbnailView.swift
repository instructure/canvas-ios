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

struct FileThumbnailView: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    let file: File
    var thumbnailSize: CGFloat = Image.defaultIconSize
    var innerIconSize: CGFloat = Image.defaultIconSize
    var iconBackgroundColor: Color = .clear
    var cornerRadius: CGFloat = 4

    var body: some View {
        if let url = file.thumbnailURL {
            RemoteImage(url, size: thumbnailSize * uiScale.iconScale)
                .cornerRadius(cornerRadius)
        } else {
            Image(uiImage: file.icon)
                .scaledIcon(size: innerIconSize, paddedTo: thumbnailSize)
                .background(iconBackgroundColor.cornerRadius(cornerRadius))
                .foregroundStyle(Color.textDarkest)
        }
    }
}

#if DEBUG

#Preview {
    let context = PreviewEnvironment().database.viewContext

    HStack {
        FileThumbnailView(
            file: File.save(.make(mime_class: "doc"), in: context)
        )

        FileThumbnailView(
            file: File.save(.make(mime_class: "doc"), in: context),
            thumbnailSize: 56,
            innerIconSize: 27,
            iconBackgroundColor: .backgroundLight,
            cornerRadius: 20
        )
    }
    .padding(20)
    .background(Color.yellow)
}

#endif
