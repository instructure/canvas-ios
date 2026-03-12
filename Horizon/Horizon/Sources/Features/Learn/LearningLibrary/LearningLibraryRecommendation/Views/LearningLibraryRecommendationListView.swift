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

struct LearningLibraryRecommendationListView: View {
    @State var viewModel: LearningLibraryRecommendationListViewModel

    var body: some View {
        if viewModel.recommendedItems.isNotEmpty {
            contentView
                .onReceive(viewModel.accessibilityMessagePublisher) { message in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIAccessibility.post(notification: .announcement, argument: message)
                    }
                }
        }
    }

    private var contentView: some View {
        Section(header: collectionView) {
            LearningLibraryRecommendationSection(
                items: viewModel.recommendedItems,
                viewModel: viewModel
            )
        }
        .plainListRowStyle()
        .animation(.smooth, value: viewModel.recommendedItems)
    }

    private var collectionView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Image.huiIcons.aiFilled
                .foregroundStyle(Color.huiColors.icon.default)
                .frame(width: 30, height: 30)
                .background(Color.huiColors.surface.cardPrimary.opacity(0.85))
                .background(Color.huiColors.surface.igniteAIPrimaryGradient)
                .clipShape(.circle)
            Text("Recommended for you")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.labelMediumBold)
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.bottom, .huiSpaces.space16)
    }
}
