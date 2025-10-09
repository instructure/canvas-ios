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

private struct SkeletonLoadKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var isSkeletonLoadActive: Bool {
        get { self[SkeletonLoadKey.self] }
        set { self[SkeletonLoadKey.self] = newValue }
    }
}

extension View {
    public func isSkeletonLoadActive(_ active: Bool) -> some View {
        environment(\.isSkeletonLoadActive, active)
    }
}

struct SkeletonLoad: ViewModifier {
    @Environment(\.isSkeletonLoadActive) private var isActive

    let isActive2: Bool?
    let topLeading: CGFloat
    let topTrailing: CGFloat
    let bottomLeading: CGFloat
    let bottomTrailing: CGFloat

    func body(content: Content) -> some View {
        if let isActive2, isActive2 {
            redactedView(content)
        } else if isActive {
            redactedView(content)
        } else {
            content
        }
    }

    @ViewBuilder
    private func redactedView(_ content: Content) -> some View {
        content
            .hidden()
            .overlay {
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
            }
            .modifier(Shimmer())
            .accessibilityHidden(true)
    }
}

extension View {
    public func skeletonLoadable(
        isActive: Bool? = nil,
        topLeading: CGFloat = 6,
        topTrailing: CGFloat = 6,
        bottomLeading: CGFloat = 6,
        bottomTrailing: CGFloat = 6
    ) -> some View {
        modifier(
            SkeletonLoad(
                isActive2: isActive,
                topLeading: topLeading,
                topTrailing: topTrailing,
                bottomLeading: bottomLeading,
                bottomTrailing: bottomTrailing
            )
        )
    }
}
