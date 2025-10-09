//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct SkeletonAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let topLeading: CGFloat
    let topTrailing: CGFloat
    let bottomLeading: CGFloat
    let bottomTrailing: CGFloat
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: Image?
    @State private var didFail: Bool = false
    @State private var isLoading: Bool = true

    public init(
        url: URL?,
        topLeading: CGFloat = 6,
        topTrailing: CGFloat = 6,
        bottomLeading: CGFloat = 6,
        bottomTrailing: CGFloat = 6,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                content(image)
            case .failure:
                placeholder()
            case .empty:
                if url != nil {
                    skeletonView
                } else {
                    placeholder()
                }
            @unknown default:
                skeletonView
            }
        }
        .id(url?.absoluteString)
    }

    private var skeletonView: some View {
        GeometryReader { proxy in
            UnevenRoundedRectangle(
                topLeadingRadius: topLeading,
                bottomLeadingRadius: bottomLeading,
                bottomTrailingRadius: bottomTrailing,
                topTrailingRadius: topTrailing
            )
            .fill(.tertiary)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .modifier(Shimmer())
        .accessibilityHidden(true)
    }
}

