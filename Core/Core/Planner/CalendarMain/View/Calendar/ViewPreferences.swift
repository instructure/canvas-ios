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

// MARK: Measuring Size

private struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    func measuringSize(_ onMeasure: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { g in
                Color.clear.preference(key: SizeKey.self, value: g.size)
            }
            .onPreferenceChange(SizeKey.self, perform: onMeasure)
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

    func measuringSize(_ value: Binding<CGSize>) -> some View {
        measuringSize { newSize in
            value.wrappedValue = newSize
        }
    }
}

extension CGSize {
    var isZero: Bool { width == 0 && height == 0 }
}

// MARK: - Collapsable

struct CollapsableViewSize: Equatable {
    let collapsed: CGSize
    let expanded: CGSize
}

private struct CollapsableViewSizeKey: PreferenceKey {
    static var defaultValue = CollapsableViewSize(collapsed: .zero, expanded: .zero)
    static func reduce(value: inout CollapsableViewSize, nextValue: () -> CollapsableViewSize) {}
}

extension View {

    func preferredCollapsableViewSize(collapsed: CGSize, expanded: CGSize) -> some View {
        preference(
            key: CollapsableViewSizeKey.self,
            value: CollapsableViewSize(
                collapsed: collapsed,
                expanded: expanded
            )
        )
    }

    func onCollapsableViewSized(_ sized: @escaping (CollapsableViewSize) -> Void ) -> some View {
        onPreferenceChange(CollapsableViewSizeKey.self, perform: sized)
    }
}
