//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct TopBarView: View {
    @ObservedObject private var viewModel: TopBarViewModel
    private let selectionIndicatorHeight: CGFloat = 3
    private let horizontalInset: CGFloat
    private let itemSpacing: CGFloat

    public init(viewModel: TopBarViewModel, horizontalInset: CGFloat, itemSpacing: CGFloat) {
        self.viewModel = viewModel
        self.horizontalInset = horizontalInset
        self.itemSpacing = itemSpacing
    }

    public var body: some View {
        ScrollViewWithReader(.horizontal, showsIndicators: false) { scrollViewProxy in
            HStack(spacing: 0) {
                ForEach(viewModel.items) { model in
                    if let itemInfo = viewModel.itemInfo(for: model) {
                        itemForModel(model, info: itemInfo, scrollViewProxy: scrollViewProxy)
                    }
                }
            }
            .overlayPreferenceValue(ViewBoundsPreferenceKey.self) { boundsPreferences in
                GeometryReader { geometry in
                    selectionIndicator(selectedItemBounds: boundsForSelectedItem(in: geometry, using: boundsPreferences))
                }
            }
            .onReceive(viewModel.$selectedItemIndex) { selectedItemIndex in
                withAnimation {
                    scrollViewProxy.scrollTo(selectedItemIndex, anchor: nil)
                }
            }
        }
    }

    private func itemForModel(_ model: TopBarItemViewModel, info: (index: Int, isFirst: Bool, isLast: Bool), scrollViewProxy: ScrollViewProxy) -> some View {
        let item = TopBarItemView(viewModel: model) {
            viewModel.selectedItemIndex = info.index
        }
        .anchorPreference(key: ViewBoundsPreferenceKey.self, value: .bounds, transform: { [ViewBoundsPreferenceData(viewId: info.index, bounds: $0)] })
        .padding(.leading, info.isFirst ? horizontalInset : (itemSpacing / 2))
        .padding(.trailing, info.isLast ? horizontalInset : (itemSpacing / 2))
        .id(info.index)

        return item
    }

    private func selectionIndicator(selectedItemBounds: CGRect) -> some View {
        Rectangle()
            .foregroundColor(Color(Brand.shared.primary))
            .frame(width: selectedItemBounds.width, height: selectionIndicatorHeight)
            .clipShape(TopBarSelectionShape())
            .offset(x: selectedItemBounds.minX, y: selectedItemBounds.maxY - selectionIndicatorHeight)
            .animation(.interactiveSpring(), value: selectedItemBounds)
    }

    private func boundsForSelectedItem(in geometry: GeometryProxy, using preferences: [ViewBoundsPreferenceData]) -> CGRect {
        let selectedItemPreference = preferences.first { $0.viewId == viewModel.selectedItemIndex }?.bounds
        let selectedItemBounds = (selectedItemPreference != nil) ? geometry[selectedItemPreference!] : .zero
        return selectedItemBounds
    }
}

#if DEBUG

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        let properties: [(horizontalInset: CGFloat, itemSpacing: CGFloat)] = [
            (16, 16),
            (0, 16),
            (32, 16),
        ]

        ForEach(0..<3) {
            TopBarView(viewModel: TopBarViewModel(items: [
                TopBarItemViewModel(id: "1", icon: .addLine, label: Text(verbatim: "Add")),
                TopBarItemViewModel(id: "2", icon: .audioLine, label: Text(verbatim: "Audio")),
                TopBarItemViewModel(id: "3", icon: .noteLine, label: Text(verbatim: "Note")),
                TopBarItemViewModel(id: "4", icon: .prerequisiteLine, label: Text(verbatim: "Prerequisite")),
            ]), horizontalInset: properties[$0].horizontalInset, itemSpacing: properties[$0].itemSpacing)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
