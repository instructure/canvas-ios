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

import SwiftUI
import HorizonUI

struct CourseImageView: View {
    // MARK: - Dependencies
    private let height: CGFloat
    private let width: CGFloat
    private let url: URL?
    private let corners: HorizonUI.Corners
    private let level: HorizonUI.CornerRadius
    private let placeholderIcon: Image
    private let iconForegroundColor: Color
    private let backgroundColor: Color
    // MARK: - Init
    init(
        height: CGFloat = 182,
        width: CGFloat,
        url: URL?,
        corners: HorizonUI.Corners = [.topLeft, .topRight],
        level: HorizonUI.CornerRadius = .level5,
        placeholderIcon: Image = Image.huiIcons.book2Filled,
        iconForegroundColor: Color = Color.huiColors.surface.institution,
        backgroundColor: Color = Color.huiColors.primitives.grey14
    ) {
        self.height = height
        self.width = width
        self.url = url
        self.corners = corners
        self.level = level
        self.placeholderIcon = placeholderIcon
        self.iconForegroundColor = iconForegroundColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        SkeletonRemoteImage(
            url: url,
            topLeading: 32,
            topTrailing: 32,
            bottomLeading: 0,
            bottomTrailing: 0,
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: height)
                .frame(maxWidth: width)
                .huiCornerRadius(level: level, corners: corners)
                .accessibilityLabel("")
                .accessibilityRemoveTraits(.isImage)
                .accessibilityHidden(true)
                .background(Color.white)
        } placeholder: {
            ZStack {
                backgroundColor
                    .huiCornerRadius(level: level, corners: corners)
                    .accessibilityHidden(true)
                placeholderIcon
                    .foregroundStyle(Color.huiColors.surface.institution)
                    .accessibilityHidden(true)
            }
        }
        .skeletonLoadable()
        .frame(height: height)
        .accessibilityLabel("")
        .accessibilityRemoveTraits(.isImage)
        .accessibilityHidden(true)
        .background(Color.white)
    }
}
