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

public extension HorizonUI {
    struct Tabs: View {
        // MARK: - Properties

        @Binding private var selectTabIndex: Int?
        @Namespace private var nameSpace

        // MARK: - Dependencies

        private let tabs: [String]

        // MARK: - Init
        public init(
            tabs: [String],
            selectTabIndex: Binding<Int?>
        ) {
            self.tabs = tabs
            self._selectTabIndex = selectTabIndex
        }

        public var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: .huiSpaces.primitives.medium) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, item in
                        Button {
                            selectTabIndex = index
                        } label: {
                            tab(title: item, isSelected: index == selectTabIndex)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, .huiSpaces.primitives.medium)
            }
            .scrollPosition(id: $selectTabIndex, anchor: .center)
            .animation(.smooth, value: selectTabIndex)
        }

        private func tab(title: String, isSelected: Bool) -> some View {
            VStack(spacing: .huiSpaces.primitives.xxxSmall) {
                Text(title)
                    .frame(maxWidth: .infinity)
                    .huiTypography(.p1)
                    .foregroundStyle(isSelected ? Color.huiColors.text.surfaceInverseSecondary : Color.huiColors.text.body)

                if isSelected {
                    Rectangle()
                        .foregroundColor(Color.huiColors.text.surfaceInverseSecondary)
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "selected", in: nameSpace)
                }
            }
        }
    }
}

#Preview {
    HorizonUI.Tabs(
        tabs: ["Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5"],
        selectTabIndex: .constant(0)
    )
}
