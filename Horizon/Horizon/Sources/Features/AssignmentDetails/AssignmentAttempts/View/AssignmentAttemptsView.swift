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

struct AssignmentAttemptsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    private let submissions: [HSubmission]
    @State private var selectedSubmission: HSubmission?
    private let didSelectSubmission: (HSubmission?) -> Void

    init(
        submissions: [HSubmission],
        selectedSubmission: HSubmission?,
        didSelectSubmission: @escaping (HSubmission?) -> Void
    ) {
        self.submissions = submissions
        self.selectedSubmission = selectedSubmission
        self.didSelectSubmission = didSelectSubmission
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space32) {
            headerView
            if submissions.isEmpty {
                Text(AssignmentLocalizedKeys.emptyAttempt.title)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .huiTypography(.p1)
            } else {
                mainContent
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var headerView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Image.huiIcons.history
                .foregroundStyle(Color.huiColors.icon.default)
                .frame(width: 24, height: 24)
            Text("Attempts", bundle: .horizon)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
            Spacer()

            HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                didSelectSubmission(selectedSubmission)
                dismiss()
            }
            .huiElevation(level: .level3)
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space8) {
                ForEach(submissions, id: \.self) { submission in
                    Button {
                        selectedSubmission = submission
                    } label: {
                        AssignmentAttemptsRow(
                            submission: submission,
                            isSelected: submission == selectedSubmission
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    AssignmentAttemptsView(
        submissions: [
            .init(id: "11", assignmentID: "submittedAt", attempt: 2),
            .init(id: "11", assignmentID: "submittedAt", attempt: 3),
            .init(id: "11", assignmentID: "submittedAt", attempt: 4)
        ],
        selectedSubmission: nil) { _ in }
}
