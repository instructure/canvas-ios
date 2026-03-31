//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import SwiftUI
import HorizonUI
import SDWebImage

struct CourseImageView: View {
    private let height: CGFloat
    private let url: URL?

    // MARK: - Init

    init(
        height: CGFloat = 182,
        url: URL?
    ) {
        self.height = height
        self.url = url
    }

    var body: some View {
        ImageLoaderView(
            url: url
        ) {
            ZStack {
                Color.huiColors.primitives.grey14
                    .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
                Image.huiIcons.book2Filled
                    .foregroundStyle(Color.huiColors.surface.institution)
                    .accessibilityHidden(true)
            }
        }
        .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        .frame(height: height)
        .clipped()
        .accessibilityLabel("")
        .accessibilityRemoveTraits(.isImage)
        .accessibilityHidden(true)
        .background(Color.white)
    }
}
