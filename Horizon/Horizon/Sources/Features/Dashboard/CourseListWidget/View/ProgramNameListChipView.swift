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

struct ProgramNameListChipView: View {
    let programs: [CourseListWidgetModel.ProgramInfo]
    let onSelect: (CourseListWidgetModel.ProgramInfo) -> Void
    var body: some View {
        HorizonUI.HFlow {
            ForEach(programs) { program in
                Button {
                    onSelect(program)
                } label: {
                    HorizonUI.StatusChip(
                        title: program.name,
                        style: .white,
                        label: String(localized: "Part of :"),
                        hasBorder: true
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProgramNameListChipView(
        programs: [
            CourseListWidgetModel.ProgramInfo(
                id: "1",
                name: "Program 1 Program 1 Program 1   Program 1  Program 1  Program 1  "
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
    ) { _ in}
        .padding()
}
