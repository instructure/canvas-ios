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
    struct DropdownMenu: View {
        @State private var isExpanded = false
        @State private var titleHeight: CGFloat = 0
        @State private var contentHeight: CGFloat?

        // MARK: - Dependencies

        private let items: [DropdownMenuItem]
        @State private var selectedItem: DropdownMenuItem?
        private let style: HorizonUI.FilterChip.Style
        private let state: HorizonUI.Chip.ChipState
        private let size: HorizonUI.Chip.Size
        private let showCheckmark: Bool
        private let onSelect: (DropdownMenuItem?) -> Void

        // MARK: - Init

        public init(
            items: [DropdownMenuItem],
            selectedItem: DropdownMenuItem? = nil,
            style: HorizonUI.FilterChip.Style,
            state: HorizonUI.Chip.ChipState,
            size: HorizonUI.Chip.Size,
            showCheckmark: Bool,
            onSelect: @escaping (DropdownMenuItem?) -> Void
        ) {
            self.items = items
            self._selectedItem = State(initialValue: selectedItem)
            self.style = style
            self.size = size
            self.onSelect = onSelect
            self.state = state
            self.showCheckmark = showCheckmark
        }

        public var body: some View {
            VStack(spacing: .zero) {
                header
                content
                    .frame(height: isExpanded ? (contentHeight ?? 0) : 0)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: isExpanded)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: titleHeight, alignment: .top)
            .zIndex(101)
        }

        @ViewBuilder
        private var header: some View {
            switch style {
            case .menu(let menu):
                HStack(spacing: .zero) {
                    if menu.headerAlignment == .trailing {
                        Spacer()
                    }
                    menuChip(menu)
                    if menu.headerAlignment == .leading {
                        Spacer()
                    }
                }
            default:
                EmptyView()
            }
        }

        private func menuChip(_ menu: HorizonUI.FilterChip.Style.MenuStyle) -> some View {
            let titleText = selectedItem?.name ?? menu.placeHolder
            let leadingIcon = (menu.showCheckmark && selectedItem != nil) ? Image.huiIcons.check : nil
            return HorizonUI.Chip(
                title: titleText,
                style: chipStyle(for: menu.kind),
                size: size,
                leadingIcon: leadingIcon,
                trallingIcon: Image.huiIcons.keyboardArrowDown
            ) {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .readingFrame { frame in
                titleHeight = frame.height
            }
        }

        private func chipStyle(for kind: HorizonUI.FilterChip.Style.MenuStyle.Kind) -> HorizonUI.Chip.Style {
            let hasSelection = selectedItem != nil
            switch kind {
            case .darkOutline:
                return .custom(
                    .init(
                        state: state,
                        foregroundColor: hasSelection
                        ? Color.huiColors.text.surfaceColored
                        : Color.huiColors.text.title,
                        backgroundNormal: hasSelection
                        ? Color.huiColors.surface.inversePrimary
                        : Color.huiColors.surface.cardPrimary,
                        backgroundPressed: hasSelection
                        ? Color.huiColors.surface.inverseSecondary
                        : Color.huiColors.surface.hover,
                        borderColor: Color.huiColors.surface.inversePrimary,
                        focusedBorderColor: Color.huiColors.surface.inversePrimary,
                        iconColor: hasSelection
                        ? Color.huiColors.text.surfaceColored
                        : Color.huiColors.surface.inversePrimary
                    )
                )
            case .grayOutline:
                return .custom(
                    .init(
                        state: state,
                        foregroundColor: Color.huiColors.text.title,
                        backgroundNormal: Color.huiColors.surface.cardPrimary,
                        backgroundPressed: Color.huiColors.surface.hover,
                        borderColor: Color.huiColors.lineAndBorders.lineStroke,
                        focusedBorderColor: Color.huiColors.lineAndBorders.lineStroke,
                        iconColor: Color.huiColors.surface.inversePrimary
                    )
                )
            case .ghost:
                return .custom(
                    .init(
                        state: state,
                        foregroundColor: Color.huiColors.text.title,
                        backgroundNormal: Color.clear,
                        backgroundPressed: Color.huiColors.surface.hover,
                        borderColor: Color.clear,
                        focusedBorderColor: Color.clear,
                        iconColor: Color.huiColors.surface.inversePrimary
                    )
                )
            }
        }

        private var content: some View {
            ScrollView {
                VStack(spacing: .zero) {
                    ForEach(items) { item in
                        itemRow(item)
                    }
                }
                .background(Color.huiColors.surface.cardPrimary)
                .readingFrame { frame in
                    if contentHeight == nil {
                        contentHeight = min(frame.height, 300)
                    }
                }
            }
            .background(Color.huiColors.surface.cardPrimary)
            .huiCornerRadius(level: .level2)
            .huiElevation(level: .level1)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.huiColors.surface.inversePrimary, lineWidth: 1)
            }
        }

        private func itemRow(_ item: DropdownMenuItem) -> some View {
            HStack(spacing: .huiSpaces.space8) {
                if selectedItem != nil {
                    Image.huiIcons.check
                        .frame(width: 18, height: 18)
                        .opacity(item == selectedItem ? 1 : 0)
                        .foregroundStyle(Color.huiColors.icon.surfaceColored)
                }
                Button {
                    selectedItem = item
                    dismiss()
                } label: {
                    Text(item.name)
                        .huiTypography(.p1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(item == selectedItem
                                         ? Color.huiColors.surface.pageSecondary
                                         : Color.huiColors.text.body)
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .frame(minHeight: 34)
            .background(item == selectedItem ? Color.huiColors.surface.inversePrimary : Color.clear)
        }

        private func dismiss() {
            withAnimation(.easeInOut(duration: 0.5)) {
                isExpanded.toggle()
            } completion: {
                onSelect(selectedItem)
            }
        }
    }

     struct DropdownMenuItem: Identifiable, Equatable {
        public let id: String
        let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }

#if DEBUG
        @MainActor static let mock: [DropdownMenuItem] = [
            .init(id: "1", name: "Option 1"),
            .init(id: "2", name: "Option 2"),
            .init(id: "3", name: "Option 3"),
            .init(id: "4", name: "Option 4")
        ]
#endif
    }
}
