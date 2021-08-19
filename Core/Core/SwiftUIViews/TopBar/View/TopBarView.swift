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
    private let leftInset: CGFloat
    private let itemSpacing: CGFloat

    public init(viewModel: TopBarViewModel, leftInset: CGFloat, itemSpacing: CGFloat) {
        self.viewModel = viewModel
        self.leftInset = leftInset
        self.itemSpacing = itemSpacing
    }

    public var body: some View {
        ScrollViewWithReader(.horizontal, showsIndicators: false) { scrollViewProxy in
            HStack(spacing: itemSpacing) {
                if leftInset > 0 {
                    Color.clear.frame(width: abs(itemSpacing - leftInset), height: 0)
                }

                ForEach(0..<viewModel.items.count) { index in
                    TopBarItemView(viewModel: viewModel.items[index]) {
                        viewModel.selectedItemIndex = index
                        withAnimation {
                            scrollViewProxy.scrollTo(index, anchor: nil)
                        }
                    }
                    .anchorPreference(key: ViewBoundsPreferenceKey.self, value: .bounds, transform: { [ViewBoundsPreferenceData(viewId: index, bounds: $0)] })
                    .id(index)
                }
            }
            .overlayPreferenceValue(ViewBoundsPreferenceKey.self) { boundsPreferences in
                GeometryReader { geometry in
                    selectionIndicator(selectedItemBounds: boundsForSelectedItem(in: geometry, using: boundsPreferences))
                }
            }
        }
    }

    private func selectionIndicator(selectedItemBounds: CGRect) -> some View {
        Rectangle()
            .foregroundColor(Color(Brand.shared.primary))
            .frame(width: selectedItemBounds.width, height: selectionIndicatorHeight)
            .clipShape(TopBarSelectionShape())
            .offset(x: selectedItemBounds.minX, y: selectedItemBounds.maxY - selectionIndicatorHeight)
            .animation(.interactiveSpring())
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
        let properties: [(leftInset: CGFloat, itemSpaing: CGFloat)] = [
            (16, 16),
            (0, 16),
            (32, 16),
        ]

        ForEach(0..<properties.count) {
            TopBarView(viewModel: TopBarViewModel(items: [
                TopBarItemViewModel(icon: .addLine, label: Text(verbatim: "Add")),
                TopBarItemViewModel(icon: .audioLine, label: Text(verbatim: "Audio")),
                TopBarItemViewModel(icon: .noteLine, label: Text(verbatim: "Note")),
                TopBarItemViewModel(icon: .prerequisiteLine, label: Text(verbatim: "Prerequisite")),
            ]), leftInset: properties[$0].leftInset, itemSpacing: properties[$0].itemSpaing)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
