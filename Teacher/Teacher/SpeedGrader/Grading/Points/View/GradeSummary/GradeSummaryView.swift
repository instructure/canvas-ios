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

struct GradeSummaryView: View {
    private let pointsRow: PointsRowViewModel?
    private let latePenaltyRow: LatePenaltyRowViewModel?
    private let finalGradeRow: FinalGradeRowViewModel?

    init(
        pointsRow: PointsRowViewModel? = nil,
        latePenaltyRow: LatePenaltyRowViewModel? = nil,
        finalGradeRow: FinalGradeRowViewModel? = nil
    ) {
        self.pointsRow = pointsRow
        self.latePenaltyRow = latePenaltyRow
        self.finalGradeRow = finalGradeRow
    }

    var body: some View {
        VStack(spacing: 0) {
            if let pointsRow {
                PointsRowView(viewModel: pointsRow)

                if latePenaltyRow != nil || finalGradeRow != nil {
                    InstUI.Divider(.padded)
                }
            }

            if let latePenaltyRow {
                LatePenaltyRowView(viewModel: latePenaltyRow)

                if finalGradeRow != nil {
                    InstUI.Divider(.padded)
                }
            }

            if let finalGradeRow {
                FinalGradeRowView(viewModel: finalGradeRow)
            }
        }
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 16) {
        GradeSummaryView(
            finalGradeRow: .init(gradeText: "85", a11yGradeText: nil, suffixType: .percentage, isGradedButNotPosted: false)
        )

        GradeSummaryView(
            finalGradeRow: .init(gradeText: "15", a11yGradeText: nil, suffixType: .maxGradeWithUnit("30 pts", ""), isGradedButNotPosted: false)
        )

        GradeSummaryView(
            finalGradeRow: .init(gradeText: "A-", a11yGradeText: nil, suffixType: .none, isGradedButNotPosted: false)
        )

        GradeSummaryView(
            pointsRow: .init(currentPoints: "15", maxPointsWithUnit: "30 pts"),
            finalGradeRow: .init(gradeText: "43", a11yGradeText: nil, suffixType: .percentage, isGradedButNotPosted: false)
        )

        GradeSummaryView(
            pointsRow: .init(currentPoints: "15", maxPointsWithUnit: "30 pts"),
            latePenaltyRow: .init(penaltyText: "-2 pts", a11yPenaltyText: nil),
            finalGradeRow: .init(gradeText: "43", a11yGradeText: nil, suffixType: .percentage, isGradedButNotPosted: false)
        )
    }
    .padding()
}

#endif
