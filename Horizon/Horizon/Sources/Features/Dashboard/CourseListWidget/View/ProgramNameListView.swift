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
    let programs: [CourseListWidgetModel.ProgramInfo]
    let onSelect: (CourseListWidgetModel.ProgramInfo) -> Void

    var body: some View {
        HorizonUI.HFlow(spacing: .huiSpaces.space4, lineSpacing: .huiSpaces.space2) {
            Text("Part of", bundle: .horizon)
                .huiTypography(.labelSmall)
                .foregroundStyle(Color.huiColors.text.timestamp)

            ForEach(programs) { program in
                let isLast = program.id == programs.last?.id

                Button {
                    onSelect(program)
                } label: {
                    (
                        Text(program.name)
                            .underline(true, color: Color.huiColors.text.body)
                        +
                        Text(verbatim: isLast ? "" : " , ")
                            .underline(false)
                    )
                    .huiTypography(.labelSmallBold)
                    .foregroundStyle(Color.huiColors.text.body)
                    .baselineOffset(2)
                    .multilineTextAlignment(.leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProgramNameListView(
        programs: [
            CourseListWidgetModel.ProgramInfo(
                id: "1",
                name: "Program 1"
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "2",
                name: "Program 2"
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "3",
                name: " Program 3 "
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "4",
                name: "Test Program 4"
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "5",
                name: "Test Program 4"
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "6",
                name: "Test Program 4"
            ),
            CourseListWidgetModel.ProgramInfo(
                id: "7",
                name: "Test Program 4"
            )
        ]
    ) { _ in }
}
