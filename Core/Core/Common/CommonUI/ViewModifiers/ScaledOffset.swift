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
    public func scaledOffset(x: CGFloat = 0, y: CGFloat = 0, useIconScale: Bool = false, alignment: Alignment = .center) -> some View {
        modifier(ScaledOffsetModifier(x: x, y: y, useIconScale: useIconScale))
    }
}

private struct ScaledOffsetModifier: ViewModifier {
    @ScaledMetric private var uiScale: CGFloat = 1

    let x: CGFloat
    let y: CGFloat
    let useIconScale: Bool

    func body(content: Content) -> some View {
        let scale = useIconScale ? uiScale.iconScale : uiScale
        content
            .offset(x: x * scale, y: y * scale)
    }
}
