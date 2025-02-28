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
import HorizonUI

struct AssignmentAttemptsRow: View {
    let submission: HSubmission
    let isSelected: Bool

    var body: some View {
        VStack(spacing: .huiSpaces.space12) {
            attemptView(submission: submission)
            Text(submission.submittedAt?.formatted(format: "d/MM, h:mm a") ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.p2)
            scoreView(submission: submission)
        }
        .padding(.huiSpaces.space16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.huiColors.surface.pageSecondary)
                .huiBorder(level: .level1,
                           color: isSelected
                           ? Color.huiColors.surface.institution
                           : Color.huiColors.lineAndBorders.lineStroke,
                           radius: 16)
        }
    }

    private func attemptView(submission: HSubmission) -> some View {
        HStack(spacing: .huiSpaces.space2) {
            Text("Attempt", bundle: .horizon)
            Text(submission.attempt.description)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.huiColors.text.body)
        .huiTypography(.p2)
    }

    @ViewBuilder
    private func scoreView(submission: HSubmission) -> some View {
        if let grade = submission.grade {
            HStack(spacing: .huiSpaces.space2) {
                Text("Score", bundle: .horizon)
                Text(grade)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p2)
        }
    }
}

#Preview {
    AssignmentAttemptsRow(
        submission: HSubmission(id: "11", assignmentID: "submittedAt", attempt: 2),
        isSelected: true
    )
}
