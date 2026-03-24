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

struct SkeletonCardView: View {
    private let color: Color
    private let title: String
    private let contextLabel: String?

    init(color: Color, title: String, contextLabel: String? = nil) {
        self.color = color
        self.title = title
        self.contextLabel = contextLabel
    }

    var body: some View {
        DashboardThumbnailCard(
            thumbnail: {
                color
                    .scaledFrame(size: 72, useIconScale: true)
            },
            labels: {
                if let contextLabel {
                    Text(contextLabel)
                        .font(.regular14, lineHeight: .fit)
                        .foregroundStyle(color)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Text(title)
                    .font(.semibold16, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            },
            isAvailableOffline: false,
            action: { }
        )
        .redacted(reason: .placeholder)
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack {
        SkeletonCardView(color: .course1, title: "Custom title")
        SkeletonCardView(color: .course2, title: "Custom title")
        SkeletonCardView(color: .course3, title: "Custom title", contextLabel: "Subtitle")
        SkeletonCardView(color: .course4, title: "Custom title", contextLabel: "Subtitle")
    }
    .padding()
}
