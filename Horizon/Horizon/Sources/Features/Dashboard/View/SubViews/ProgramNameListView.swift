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

struct ProgramNameListView: View {
    let programs: [Program]
    let onSelect: (Program) -> Void
    var body: some View {
        VStack(alignment: .leading) {
            HorizonUI.HFlow {
                Text("Part of", bundle: .horizon)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(alignment: .leading)

                ForEach(programs) { program in
                    Button {
                        onSelect(program)
                    } label: {
                        Text(program.name)
                            .underline()
                            .foregroundStyle(Color.huiColors.text.body)
                            .huiTypography(.buttonTextLarge)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ProgramNameListView(
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
