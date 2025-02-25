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
    let submissions: [HSubmission] = []
    var body: some View {
        VStack(spacing: .huiSpaces.space32) {
            headerView

            ScrollView {
                attemptRow(submission: .init(id: "", assignmentID: ""))
            }
            Spacer()

        }
        .padding(.huiSpaces.space24)
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
                dismiss()
            }
            .huiElevation(level: .level3)
        }
    }

    private func attemptRow(submission: HSubmission) -> some View {
        VStack {
            HStack {
                Text("Attempt", bundle: .horizon)

                Text("ss")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p2)

            Text(submission.postedAt?.formatted(format: "d/MM, h:mm a") ?? "dsdsds")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.huiSpaces.space16)
        .huiBorder(level: .level1, color: Color.huiColors.lineAndBorders.lineStroke, radius: 16)
    }
}

#Preview {
    AssignmentAttemptsView()
}
