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
import HorizonUI
import Core

struct DropdownMenu: View {
    // MARK: - Dependencies

    private let items: [DropdownMenuItem]
    @State private var selectedItem: DropdownMenuItem?
    private let onSelect: (DropdownMenuItem?) -> Void

    // MARK: - Propertites Private

    @State private var isExpanded = false
    @State private var titleHeight: CGFloat = 0
    @State private var contentHeight: CGFloat?

    // MARK: - Init

    init(
        items: [DropdownMenuItem],
        selectedItem: DropdownMenuItem? = nil,
        onSelect: @escaping (DropdownMenuItem?) -> Void
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: .zero) {
            titleView
            contentView
                .frame(height: isExpanded ? (contentHeight ?? 0) : 0)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: isExpanded)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: titleHeight, alignment: .top)
        .zIndex(101)
    }

    private var titleView: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }

        } label: {
            HStack(alignment: .top) {
                Text(selectedItem?.name ?? "")
                    .huiTypography(.h3)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color.huiColors.primitives.black174)

                Image.huiIcons.keyboardArrowUp
                    .tint(Color.huiColors.icon.default)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut, value: isExpanded)
                    .frame(width: 24, height: 24)
                Spacer()
            }
        }
        .readingFrame { frame in
            titleHeight = frame.height
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space16) {
                ForEach(items) { item in
                    HStack(spacing: .huiSpaces.space8) {
                        Image.huiIcons.check
                            .frame(width: 18, height: 18)
                            .hidden(item != selectedItem)
                        Button {
                            selectedItem = item
                            dimissView()
                        } label: {
                            Text(item.name)
                                .foregroundStyle(Color.huiColors.text.body)
                                .huiTypography(.p1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .padding(.huiSpaces.space10)
            .background(Color.huiColors.surface.cardPrimary)
            .background(Color.blue)
            .readingFrame { frame in
                if contentHeight == nil {
                    contentHeight = min(frame.height, 300)
                }
            }
        }
        .background(Color.huiColors.surface.cardPrimary)
        .background(Color.red)
        .huiCornerRadius(level: .level1)
        .huiElevation(level: .level1)
    }

    private func dimissView() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isExpanded.toggle()
        } completion: {
            onSelect(selectedItem)
        }
    }
}

struct DropdownMenuItem: Identifiable, Equatable {
    let id: String
    let name: String
}

#Preview {
    ZStack {
        Rectangle()
            .fill(.gray)
        DropdownMenu(
            items: [
                .init(id: "1", name: "Option 1"),
                .init(id: "2", name: "Option 2"),
                .init(id: "3", name: "Option 3"),
                .init(id: "4", name: "Option 4"),
                .init(id: "5", name: "Option 5")
            ],
            selectedItem: .init(id: "2", name: "Option 2"),
            onSelect: { _ in}
        )
        .padding()
    }
}
