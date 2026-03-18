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

import Core
import HorizonUI
import SwiftUI

struct CollectionItemFilterView: View {
    @Environment(\.viewController) private var viewController
    @State var viewModel: CollectionItemFilterViewModel

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            headerView
                .padding([.horizontal, .top], .huiSpaces.space16)
            Divider()
            sortByView
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.bottom, .huiSpaces.space8)
            itemTypeView
                .padding(.horizontal, .huiSpaces.space16)

            Spacer()

            footerView
        }
        .background(Color.huiColors.surface.overlayWhite)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "Filter and sort"))
    }

    private var headerView: some View {
        FilterSortHeaderView {
            viewModel.dismiss(viewController: viewController)
        }
    }

    private var sortByView: some View {
        SortView(selectedOption: viewModel.selectedSortOption) { item in
            viewModel.toggleSortOption(item)
        }
    }

    private var itemTypeView: some View {
        VStack(spacing: .huiSpaces.space8) {
            Text("Item type")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.labelMediumBold)
                .accessibilityAddTraits(.isHeader)

            HorizonUI.HFlow {
                ForEach(CollectionItemFilterType.allCases, id: \.self) { item in
                    FilterButton(title: item.name, isSelected: viewModel.selectedFilterTypes.contains(item)) {
                        viewModel.toggleFilterType(item)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .contain)
        }
        .accessibilityElement(children: .contain)
    }

    private var footerView: some View {
        FilterSortFooterView {
            viewModel.apply(viewController: viewController)
        } onTapClear: {
            viewModel.clearFilter(viewController: viewController)
        }
    }
}

#Preview {
    CollectionItemFilterView(
        viewModel: .init(
            router: AppEnvironment.shared.router,
            onSetSortOption: { _, _ in }
        )
    )
}
