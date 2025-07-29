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
import Core

struct RubricTextRatingsListView: View {

    @Binding var isExpanded: Bool
    @ObservedObject var viewModel: RedesignedRubricCriterionViewModel

    @State private var selection: String?

    var body: some View {
        if isExpanded {
            VStack(spacing: 0) {
                let ratingModels = Array(viewModel.ratingViewModels.reversed())
                let lastRatingId = ratingModels.last?.id
                ForEach(ratingModels) { ratingViewModel in

                    HStack(alignment: .top, spacing: 0) {
                        InstUI
                            .RadioButton(isSelected: ratingViewModel.isSelected)
                            .paddingStyle(.trailing, .cellIconText)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(ratingViewModel.bubble.title)
                                .textStyle(.cellLabel)
                            Text(ratingViewModel.bubble.subtitle)
                                .font(.regular14)
                                .foregroundStyle(Color.textDarkest)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        ratingViewModel.isSelected.toggle()
                    }

                    InstUI.Divider(isLast: ratingViewModel.id != lastRatingId)
                }
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 16)

        } else if let bubble = viewModel.userRatingBubble {

            VStack(alignment: .leading) {
                Text(bubble.title)
                    .font(.semibold16)
                    .foregroundStyle(Color.textLightest)

                if bubble.subtitle.isNotEmpty {
                    Text(bubble.subtitle)
                        .font(.regular14)
                        .foregroundStyle(Color.textLightest)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(content: {
                RoundedRectangle(cornerRadius: 24).fill(.tint)
            })
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
