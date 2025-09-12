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

import HorizonUI
import SwiftUI

struct ProgramOverviewListView: View {
    let programs: [Program]
    let onSelect: (Program) -> Void
    var body: some View {
        ForEach(programs) { program in
            programView(program: program)
        }
    }

    private func programView(program: Program) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(program.name)
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.h2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, .huiSpaces.space12)

            Text("Welcome! View your program to enroll in your first course.", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.p1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, .huiSpaces.space24)

            HorizonUI.PrimaryButton(String(localized: "My program", bundle: .horizon)) {
                onSelect(program)
            }
        }
    }
}

#Preview {
    ProgramOverviewListView(
        programs: [
            Program(
                id: "1",
                name: "Program 1",
                variant: "",
                description: nil,
                date: nil,
                courseCompletionCount: nil,
                courses: []
            ),
            Program(
                id: "2",
                name: "Program 2",
                variant: "",
                description: nil,
                date: nil,
                courseCompletionCount: nil,
                courses: []
            ),
            Program(
                id: "3",
                name: " Program 3 ",
                variant: "",
                description: nil,
                date: nil,
                courseCompletionCount: nil,
                courses: []
            ),
            Program(
                id: "4",
                name: "Test Program 4",
                variant: "",
                description: nil,
                date: nil,
                courseCompletionCount: nil,
                courses: []
            )
        ]
    ) { _ in }
}
