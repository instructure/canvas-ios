//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

extension View {

    /// Overlays a published/unpublished icon in the bottom trailing corner.
    /// Intended to be used over icons with size of `24`.
    /// If the icon size is custom, then the size and offsets used here will need to be customized as well.
    public func publishedStateOverlay(isPublished: Bool?, bgColor: Color = .backgroundLightest) -> some View {
        overlay(alignment: .bottomTrailing) {
            if let isPublished {
                icon(isPublished)
                    .scaledIcon(size: 18)
                    .foregroundStyle(isPublished ? .textSuccess : .textDark)
                    .background(
                        Circle().fill(bgColor)
                    )
                    .scaledOffset(x: 4, y: 8, useIconScale: true)
            }
        }
    }

    private func icon(_ isPublished: Bool) -> Image {
        isPublished ? .publishSolid : .noSolid
    }
}

#if DEBUG

#Preview {
    PreviewContainer(spacing: 16) {
        HStack {
            Image.assignmentLine.publishedStateOverlay(isPublished: nil)
            Image.assignmentLine.publishedStateOverlay(isPublished: true)
            Image.assignmentLine.publishedStateOverlay(isPublished: false)
        }
        HStack {
            Image.assignmentLine.publishedStateOverlay(isPublished: nil)
            Image.assignmentLine.publishedStateOverlay(isPublished: true)
            Image.assignmentLine.publishedStateOverlay(isPublished: false)
        }
        .padding(10)
        .background(.yellow.opacity(0.4))
        HStack {
            Image.discussionLine.publishedStateOverlay(isPublished: nil)
            Image.discussionLine.publishedStateOverlay(isPublished: true)
            Image.discussionLine.publishedStateOverlay(isPublished: false)
        }
        HStack {
            Image.quizLine.publishedStateOverlay(isPublished: nil)
            Image.quizLine.publishedStateOverlay(isPublished: true)
            Image.quizLine.publishedStateOverlay(isPublished: false)
        }
    }
}

#endif
