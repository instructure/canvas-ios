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

struct RubricRatingExpandedView: View {
    @ObservedObject var viewModel: RubricRatingViewModel

    var body: some View {

        let halign: VerticalAlignment = viewModel.bubble.subtitle.isEmpty ? .center : .top

        HStack(alignment: halign, spacing: 16) {

            Text(viewModel.value)
                .font(.regular16)
                .foregroundColor(viewModel.isSelected ? .textLightest : .textDarkest)
                .padding(.top, 8)
                .padding(.bottom, 11)
                .padding(.horizontal, 16)
                .background(
                    !viewModel.isSelected ? RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium) : nil
                )

            let textColor: Color = viewModel.isSelected ? .textLightest : .textDarkest

            VStack(alignment: .leading) {
                let bubble = viewModel.bubble

                Text(bubble.title)
                    .font(.semibold16)
                    .foregroundStyle(textColor)

                if bubble.subtitle.isNotEmpty {
                    Text(bubble.subtitle)
                        .font(.regular14)
                        .foregroundStyle(textColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            viewModel.isSelected ? RoundedRectangle(cornerRadius: 24).fill(.tint) : nil
        )
        .contentShape(Rectangle())
        .accessibility(addTraits: viewModel.isSelected ? [.isButton, .isSelected] : .isButton)
        .onTapGesture { viewModel.isSelected.toggle() }
    }
}

#if DEBUG

#Preview {
    let env = PreviewEnvironment()
    let context = env.database.viewContext
    let model = {
        let model = RubricRatingViewModel(
            rating: CDRubricRating(context: context).with { rat in
                rat.points = 3
                rat.shortDescription = "Excellent"
                // rat.longDescription = "Comprehensive, insightful, and relevant. Information is completely accurate."
            },
            criterionId: "123",
            interactor: RubricGradingInteractorPreview()
        )
        model.isSelected = true
        return model
    }()

    VStack {
        RubricRatingExpandedView(viewModel: model)
    }
}

#endif
