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

struct UnenrolledProgramListWidgetView: View {
    let programs: [Program]
    let onTap: (Program) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            ForEach(programs) { program in
                UnenrolledProgramWidgetView(
                    program: program,
                    onTap: onTap
                )
            }
        }
    }
}

#Preview {
    UnenrolledProgramListWidgetView(
        programs:
            [
            .init(
                id: "1",
                name: "Dolor Sit Amet Program",
                variant: "",
                description: "",
                date: nil,
                courseCompletionCount: 10,
                courses: []
            ),
            .init(
                id: "2",
                name: "Dolor Sit Amet Program - 2",
                variant: "",
                description: "",
                date: nil,
                courseCompletionCount: 10,
                courses: []
            )
        ]
    ) { _ in }
}
