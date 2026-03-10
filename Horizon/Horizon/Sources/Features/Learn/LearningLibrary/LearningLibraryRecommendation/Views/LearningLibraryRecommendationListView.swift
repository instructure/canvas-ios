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

struct LearningLibraryRecommendationListView: View {
    @State var viewModel = LearningLibraryRecommendationListViewModel()
    var body: some View {
//        VStack {
            ForEach(viewModel.sections) { section in
                Section(header: collectionView) {
                    LearningLibraryRecommendationSection(items: section.items)
                }
                .plainListRowStyle()
            }
//        }
    }

    private var collectionView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Image.huiIcons.stacksFilled
                .foregroundStyle(Color.huiColors.primitives.grey45)
                .padding(.huiSpaces.space8)
                .background(Color.huiColors.primitives.grey12)
                .clipShape(.circle)
            Text("Collections")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.labelMediumBold)
        }
        .padding(.horizontal, .huiSpaces.space24)
    }
}
