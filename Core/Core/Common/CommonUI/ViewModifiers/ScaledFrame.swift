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

extension View {
    @ViewBuilder
    public func scaledFrame(width: CGFloat? = nil, height: CGFloat? = nil, useIconScale: Bool = false, alignment: Alignment = .center) -> some View {
        modifier(ScaledFrameModifier(width: width, height: height, useIconScale: useIconScale, alignment: alignment))
    }

    @ViewBuilder
    public func scaledFrame(size: CGFloat? = nil, useIconScale: Bool = false, alignment: Alignment = .center) -> some View {
        modifier(ScaledFrameModifier(width: size, height: size, useIconScale: useIconScale, alignment: alignment))
    }
}

private struct ScaledFrameModifier: ViewModifier {
    @ScaledMetric private var uiScale: CGFloat = 1

    let width: CGFloat?
    let height: CGFloat?
    let useIconScale: Bool
    let alignment: Alignment

    func body(content: Content) -> some View {
        let scale = useIconScale ? uiScale.iconScale : uiScale
        content
            .frame(
                width: width.map { scale * $0 },
                height: height.map { scale * $0 },
                alignment: alignment
            )
    }
}
