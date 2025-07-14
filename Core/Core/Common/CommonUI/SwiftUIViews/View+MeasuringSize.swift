//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

private struct MeasuredSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    public func measuringSize(_ onMeasure: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { g in
                Color.clear.preference(key: MeasuredSizeKey.self, value: g.size)
            }
            .onPreferenceChange(MeasuredSizeKey.self, perform: onMeasure)
        }
    }

    public func measuringSize(_ value: Binding<CGSize>) -> some View {
        measuringSize { newSize in
            value.wrappedValue = newSize
        }
    }

    @ViewBuilder
    func measuringSizeOnce(_ value: Binding<CGSize>) -> some View {
        if value.wrappedValue.isZero {
            measuringSize { newSize in
                value.wrappedValue = newSize
            }
        } else {
            self
        }
    }

    public func onSizeChange(_ perform: @escaping (CGSize) -> Void) -> some View {
        onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { size in
            perform(size)
        }
    }

    public func onSizeChange(update binding: Binding<CGSize>) -> some View {
        onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { size in
            binding.wrappedValue = size
        }
    }

    public func onHeightChange(_ perform: @escaping (CGFloat) -> Void) -> some View {
        onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.height
        } action: { height in
            perform(height)
        }
    }

    public func onHeightChange(update binding: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.height
        } action: { height in
            binding.wrappedValue = height
        }
    }
}
