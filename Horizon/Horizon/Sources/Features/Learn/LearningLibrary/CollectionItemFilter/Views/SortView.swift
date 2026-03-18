//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

struct SortView: View {
    let selectedOption: CollectionItemSortOption?
    let onSelect: (CollectionItemSortOption) -> Void
    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text("Sort by")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.labelMediumBold)
                .accessibilityAddTraits(.isHeader)

            HorizonUI.HFlow {
                ForEach(CollectionItemSortOption.allCases, id: \.self) { item in
                    FilterButton(title: item.name, isSelected: selectedOption == item) {
                        onSelect(item)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .contain)
        }
        .accessibilityElement(children: .contain)
    }
}
