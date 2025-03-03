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

public extension HorizonUI {
    struct SegmentedControl: View {
        // MARK: - Properties

        @Namespace private var nameSpace
        private let cornerRadius: CornerRadius = .level6

        // MARK: - Dependencies

        private let items: [String]
        private let icon: SegmentedControl.Icon
        private let iconAlignment: SegmentedControl.IconAlignment
        private let isShowIconForAllItems: Bool
        @Binding private var selectedIndex: Int

        // MARK: - Init
        public init(
            items: [String],
            icon: SegmentedControl.Icon = .none,
            iconAlignment: SegmentedControl.IconAlignment = .trailing,
            isShowIconForAllItems: Bool = true,
            selectedIndex: Binding<Int>
        ) {
            self.items = items
            self.icon = icon
            self.iconAlignment = iconAlignment
            self.isShowIconForAllItems = isShowIconForAllItems
            self._selectedIndex = selectedIndex
        }

        public var body: some View {
            HStack(alignment: .center, spacing: .zero) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Button {
                        selectedIndex = index
                    } label: {
                        segmentView(title: item, isSelected: index == selectedIndex)
                    }
                    .id(index)
                    .frame(maxWidth: .infinity)
                }
            }
            .animation(.smooth, value: selectedIndex)
            .frame(height: 44)
            .background {
                Rectangle()
                    .fill(.clear)
                    .huiBorder(
                        level: .level2,
                        color: Color.huiColors.lineAndBorders.lineStroke,
                        radius: cornerRadius.attributes.radius
                    )
            }
        }

        @ViewBuilder
        private func segmentView(title: String, isSelected: Bool) -> some View {
            HStack(spacing: .huiSpaces.space4) {
                if iconAlignment == .leading { icon(forSelected: isSelected) }
                Text(title)
                    .huiTypography(.buttonTextLarge)
                    .foregroundStyle(
                        isSelected
                        ? Color.huiColors.surface.institution
                        : Color.huiColors.text.placeholder
                    )

                if iconAlignment == .trailing { icon(forSelected: isSelected) }
            }
            .padding(.vertical, .huiSpaces.space10)
            .frame(maxWidth: .infinity)
            .overlay {
                if isSelected { selectedSegmentView }
            }
        }

        @ViewBuilder
        private func icon(forSelected: Bool) ->  some View {
            if let icon = icon.icon {
                icon.foregroundStyle(forSelected ? Color.huiColors.surface.institution: Color.huiColors.text.placeholder)
                    .opacity(opacityForIcon(isSelected: forSelected))
            }
        }

        private func opacityForIcon(isSelected: Bool) -> Double {
            if isShowIconForAllItems {
                return 1
            }
            return isSelected ? 1 : 0
        }

        private var selectedSegmentView: some View {
            Rectangle()
                .fill(.clear)
                .huiBorder(
                    level: .level2,
                    color: Color.huiColors.surface.institution,
                    radius: cornerRadius.attributes.radius
                )
                .matchedGeometryEffect(id: "selected", in: nameSpace)
                .frame(height: 44)
                .background {
                    Rectangle()
                        .fill(Color.huiColors.surface.institution.opacity(0.05))
                        .huiCornerRadius(level: .level6)
                }
        }
    }
}

#Preview {
    @Previewable @State var selectedIndex: Int = 0
    HorizonUI.SegmentedControl(
        items: [
            "Item 1" ,
            "Item 2",
            "Item 3"
        ],
        selectedIndex: $selectedIndex
    )
    .padding()
}
