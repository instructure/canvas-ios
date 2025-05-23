//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
public struct OldSegmentedPicker<Element, Content>: View where Content: View {
    public typealias Data = [Element]

    @State private var frames: [CGRect]
    @Binding private var selectedIndex: Data.Index?

    private let data: Data
    private let content: (Data.Element, Bool) -> Content
    private let selectionAlignment: VerticalAlignment

    public init(
        _ data: Data,
        selectedIndex: Binding<Data.Index?>,
        selectionAlignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping (Data.Element, Bool) -> Content
    ) {
        self.data = data
        self.content = content
        _selectedIndex = selectedIndex
        _frames = State(wrappedValue: Array(repeating: .zero,
                                            count: data.count))
        self.selectionAlignment = selectionAlignment
    }

    public var body: some View {
        ZStack(
            alignment: Alignment(
                horizontal: .horizontalCenterAlignment,
                vertical: selectionAlignment
            )
        ) {
            if let selectedIndex = selectedIndex {
                Rectangle()
                    .foregroundColor(.textInfo)
                    .frame(width: frames[selectedIndex].width, height: 1.5)
                    .alignmentGuide(.horizontalCenterAlignment) { dimensions in
                        dimensions[HorizontalAlignment.center]
                    }
                    .animation(.easeInOut, value: selectedIndex)
            }

            HStack(spacing: 0) {
                ForEach(data.indices, id: \.self) { index in
                    VStack {
                        Button(
                            action: { selectedIndex = index },
                            label: { content(data[index], selectedIndex == index) }
                        )
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, minHeight: 33)
                        .background(GeometryReader { proxy in
                            Color.clear.onAppear { frames[index] = proxy.frame(in: .global) }
                        })
                        .alignmentGuide(
                            .horizontalCenterAlignment,
                            isActive: selectedIndex == index
                        ) { dimensions in
                            dimensions[HorizontalAlignment.center]
                        }
                        .accessibilityAddTraits(selectedIndex == index ? [.isSelected] : [])
                        .accessibilityValue(Text("\(index + 1) of \(data.indices.count)", bundle: .core, comment: "Example: 1 of 3"))
                    }

                    if index != data.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity)
        }
    }
}
