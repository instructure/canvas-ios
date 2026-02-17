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

struct ListLearningLibraryView: View {
    @State private var isExpanded: Bool = true
    @Environment(\.viewController) private var viewController
    let section: LearningLibrarySectionModel
    let viewModel: LearningLibraryViewModel
    let availableWidth: CGFloat
    let isExpendable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space24) {
            headerView

            if isExpanded {
                VStack(spacing: .huiSpaces.space24) {
                    itemsView
                    viewAllCollectionsButton
                }
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text(section.name)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            Spacer()

            if isExpendable {
                HorizonUI.IconButton(
                    isExpanded ? Image.huiIcons.keyboardArrowUp : Image.huiIcons.keyboardArrowDown,
                    type: .darkOutline,
                    isSmall: true
                ) {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }
            }
        }
    }

    private var itemsView: some View {
        ForEach(section.sortedItems) { item in
            LearningLibraryCardView(
                model: item,
                width: availableWidth,
                isBookmarkLoading: viewModel.isBookmarkLoading(forItemWithId: item.id),
                isEnrollLoading: viewModel.isEnrollLoading(forItemWithId: item.id),
                onBookmarkTap: {
                    viewModel.addBookmark(model: item)
                }, enrollTap: {
                    viewModel.enroll(model: item)
                }, onTapItem: {
                    viewModel.navigateToItem(model: item, viewController: viewController)
                }
            )
            .id(item.id)
        }
    }

    @ViewBuilder
    private var viewAllCollectionsButton: some View {
        if section.hasMoreItems {
            HStack {
                Text(String(format: String(localized: "%d items"), section.items.count))
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                HorizonUI.PrimaryButton(String(localized: "View full collection"),
                    type: .white,
                    fillsWidth: false,
                    trailing: Image.huiIcons.arrowForward
                ) {
                    viewModel.navigateToDetails(section: section, viewController: viewController)
                }
                .huiElevation(level: .level2)
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

#Preview {
    ListLearningLibraryView(
        section: LearningLibrarySectionModel(
            id: "1",
            name: "Learning Library Name",
            hasMoreItems: true,
            items: [
                .init(
                    id: "ID-1",
                    name: "Adipiscing Elit Learning Object Name Here",
                    imageURL: nil,
                    itemType: .assessment,
                    estimatedTime: "10 mins",
                    isRecommended: true,
                    isCompleted: true,
                    isBookmarked: true,
                    numberOfUnits: 10
                )
            ]
        ),
        viewModel: LearningLibraryViewModel(router: AppEnvironment.shared.router),
        availableWidth: 343,
        isExpendable: true
    )
    .padding()
    .background(Color.huiColors.surface.cardSecondary)
}
