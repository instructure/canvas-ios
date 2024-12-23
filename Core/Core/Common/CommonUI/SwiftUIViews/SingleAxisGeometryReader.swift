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

struct SingleAxisGeometryReader<Content: View>: View {
    private struct SizeKey: PreferenceKey {
        static var defaultValue: CGFloat { 10 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    @State private var size: CGFloat?

    private let axis: Axis
    private let alignment: Alignment
    private let initialSize: CGFloat
    private let content: (CGFloat) -> Content

    /// A GeometryReader that only reads the given axis and doesn't fill its' container view space on the opposing axis.
    /// - Parameters:
    ///     - axis: The axis to be read by the GeometryReader.
    ///     - alignment: The alignment on the given axis.
    ///     - initialSize: SwiftUI doesn't read the corret size on the first pass so you should give an initial value that somewhat matches the desired width or height.
    ///     - content: The return value is the content that will be drawn. The parameter is the result of the GeometryReader reading. If it's a horiziontal reader, then the parameter is a width value.
    ///       If it's a vertical reader, then the parameter is a height value.
    init(
        axis: Axis = .horizontal,
        alignment: Alignment = .center,
        initialSize: CGFloat,
        content: @escaping (CGFloat) -> Content
    ) {
        self.axis = axis
        self.alignment = alignment
        self.initialSize = initialSize
        self.content = content
    }

    var body: some View {
        content(size ?? initialSize)
            .frame(
                maxWidth: axis == .horizontal ? .infinity : nil,
                maxHeight: axis == .vertical ? .infinity : nil,
                alignment: alignment
            )
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizeKey.self,
                        value: axis == .horizontal ? proxy.size.width : proxy.size.height
                    )
                }
            )
            .onPreferenceChange(SizeKey.self) { size = $0 }
    }
}
