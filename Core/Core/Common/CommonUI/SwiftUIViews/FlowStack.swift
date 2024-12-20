//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

/// A view that arranges its children in horizontal lines
///
/// Use `alignmentGuide(_:computeValue:)` on children to
/// position each, passing in the given values for `computeValue`:
///
///     FlowStack { leading, top in
///         ForEach(1..<100) { num in
///             Text(String(num))
///                 .padding(8)
///                 .background(Circle().fill(Color.red))
///                 .alignmentGuide(.leading, computeValue: leading)
///                 .alignmentGuide(.top, computeValue: top)
///         }
///     }
///
public struct FlowStack<Content: View>: View {
    public typealias ComputeValue = (ViewDimensions) -> CGFloat

    let content: (@escaping ComputeValue, @escaping ComputeValue) -> Content
    let spacing: UIOffset

    @State var height: CGFloat = 0

    /// Creates an instance with the given spacing and content.
    ///
    /// - Parameter spacing: A `UIOffset` value indicating the space between children.
    /// - Parameter content: A view builder that creates the content of this stack.
    public init(
        spacing: UIOffset = .zero,
        @ViewBuilder content: @escaping (@escaping ComputeValue, @escaping ComputeValue) -> Content
    ) {
        self.content = content
        self.spacing = spacing
    }

    public var body: some View {
        GeometryReader { geometry in
            self.stack(in: geometry)
        }.frame(height: height)
    }

    private func stack(in geometry: GeometryProxy) -> some View {
        var x: CGFloat = 0, y: CGFloat = 0, maxY: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            // Reset for next layout pass
            Color.clear.alignmentGuide(.top) { _ in
                x = 0
                y = 0
                maxY = 0
                return 0
            }

            content({ item in
                if x + item.width > geometry.size.width {
                    x = 0
                    y += item.height + spacing.vertical
                }
                maxY = max(maxY, y + item.height)
                let result = x
                x += item.width + spacing.horizontal
                return -result
            }, { _ in
                -y
            })

            // Save calculated height
            Color.clear.alignmentGuide(.top) { _ in
                if maxY != height { DispatchQueue.main.async {
                    height = maxY
                } }
                return 0
            }
        }
    }
}

#if DEBUG
struct FlowStack_Previews: PreviewProvider {
    static var previews: some View {
        FlowStack { leading, top in
            ForEach(1..<100) { num in
                Text(String(num))
                    .frame(minWidth: 30, minHeight: 30)
                    .background(Circle().fill(Color.red))
                    .alignmentGuide(.leading, computeValue: leading)
                    .alignmentGuide(.top, computeValue: top)
            }
        }
    }
}
#endif
