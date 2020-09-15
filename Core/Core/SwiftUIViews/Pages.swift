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

@available(iOSApplicationExtension 13.0, *)
public struct Pages<Item: Identifiable, Content: View>: View {
    public typealias ContentBuilder = (Item) -> Content

    let items: [Item]
    let content: ContentBuilder
    @Binding var currentIndex: Int

    @Environment(\.layoutDirection) var layoutDirection
    @GestureState var translation: CGFloat = 0

    var spacing: CGFloat = 0
    var scaling: (CGFloat) -> CGFloat = { _ in 1 }

    var minIndex: Int { max(0, currentIndex - 1) }
    var maxIndex: Int { min(items.count, currentIndex + 2) }
    var dx: CGFloat { layoutDirection == .rightToLeft ? -1 : 1 }

    func show(index: Int) {
        currentIndex = min(max(index, 0), items.count - 1)
    }

    func scale(for item: Item, width: CGFloat) -> CGFloat {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return 1 }
        let offset = CGFloat(index - currentIndex) + translation / width
        return scaling(offset)
    }

    public init(items: [Item], currentIndex: Binding<Int>, @ViewBuilder content: @escaping ContentBuilder) {
        self.items = items
        self.content = content
        self._currentIndex = currentIndex
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.spacing) {
                ForEach(self.items[self.minIndex..<self.maxIndex]) { item in
                    self.content(item)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(self.scale(for: item, width: geometry.size.width), anchor: .center)
                }
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex - self.minIndex) * (geometry.size.width + self.spacing))
            .offset(x: self.translation)
            .animation(.interactiveSpring())
            .gesture(DragGesture()
                .updating(self.$translation) { value, state, _ in
                    state = value.translation.width * self.dx
                }
                .onEnded { value in
                    let offset = Int((value.translation.width * self.dx / geometry.size.width).rounded())
                    self.show(index: self.currentIndex - offset)
                }
            )
            .accessibilityScrollAction { edge in
                let offset = edge == .leading || edge == .top ? -1 : 1
                self.show(index: self.currentIndex - offset)
            }
        }
            .clipped()
    }

    public func spaceBetween(_ spacing: CGFloat) -> Self {
        var modified = self
        modified.spacing = spacing
        return modified
    }

    public func scaleEach(_ scaling: @escaping (CGFloat) -> CGFloat) -> Self {
        var modified = self
        modified.scaling = scaling
        return modified
    }
}
