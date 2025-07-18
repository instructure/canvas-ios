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

struct FinalGradeRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let viewModel: FinalGradeRowViewModel

    init(viewModel: FinalGradeRowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("Final Grade", bundle: .teacher)
                .font(.semibold16, lineHeight: .fit)
                .foregroundColor(.textDarkest)
                .paddingStyle(.trailing, .cellAccessoryPadding)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.currentGradeText)
                .font(.semibold16, lineHeight: .fit)
                .foregroundColor(.textDarkest)

            Text(viewModel.suffixText)
                .font(.regular16, lineHeight: .fit)
                .foregroundColor(.textDark)
        }
        .paddingStyle(set: .standardCell)
        .padding(.vertical, 2)
        .background(.backgroundLightest)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        FinalGradeRowView(viewModel: .init(
            currentGradeText: nil,
            suffixType: .maxGradeWithUnit("30 pts")
        ))
        FinalGradeRowView(viewModel: .init(
            currentGradeText: "15",
            suffixType: .maxGradeWithUnit("30 pts")
        ))
        FinalGradeRowView(viewModel: .init(
            currentGradeText: nil,
            suffixType: .percentage
        ))
        FinalGradeRowView(viewModel: .init(
            currentGradeText: "50",
            suffixType: .percentage
        ))
        FinalGradeRowView(viewModel: .init(
            currentGradeText: "Complete",
            suffixType: .none
        ))
        FinalGradeRowView(viewModel: .init(
            currentGradeText: "A-",
            suffixType: .none
        ))
    }
    .frame(maxHeight: .infinity)
    .background(.backgroundDarkest)
}

#endif
