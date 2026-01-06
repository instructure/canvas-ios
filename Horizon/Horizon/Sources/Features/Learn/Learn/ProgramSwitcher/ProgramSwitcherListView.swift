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

struct ProgramSwitcherListView: View {
    let programs: [ProgramSwitcherModel]
    let selectedProgram: ProgramSwitcherModel?
    let focusedProgramID: AccessibilityFocusState<String?>.Binding
    let selectedCourse: ProgramSwitcherModel.Course?
    let onSelectProgram: (ProgramSwitcherModel) -> Void
    let onSelectCourse: (ProgramSwitcherModel.Course) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            ForEach(programs) { program in
                if program.id != nil {
                    Button {
                        onSelectProgram(program)
                    } label: {
                        programView(
                            program: program,
                            isSelected: program == selectedProgram
                        )
                    }
                } else {
                    ForEach(program.courses) { course in
                        Button {
                            onSelectCourse(course)
                        } label: {
                            ProgramSwitcherCourseView(
                                course: course,
                                isSelected: course == selectedCourse
                            )
                        }
                    }
                }
            }
        }
        .background(Color.huiColors.surface.cardPrimary)
        .huiCornerRadius(level: .level2)
        .huiElevation(level: .level1)
    }

    private func programView(program: ProgramSwitcherModel, isSelected: Bool) -> some View {
        HStack(spacing: .huiSpaces.space8) {
            Text(program.name.defaultToEmpty)
                .foregroundStyle(isSelected ? Color.huiColors.surface.pageSecondary : Color.huiColors.text.body)
                .huiTypography(.buttonTextLarge)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 42)
            Spacer()
            Image.huiIcons.arrowForward
                .foregroundStyle(isSelected ? Color.huiColors.surface.pageSecondary : Color.huiColors.icon.default)
        }
        .id(program.id)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space24)
        .background(isSelected ? Color.huiColors.surface.inverseSecondary : Color.clear)
        .accessibilityElement(children: .ignore)
        .accessibilityFocused(focusedProgramID, equals: program.id)
        .accessibilityLabel(program.name.defaultToEmpty)
        .accessibilityAddTraits(program == selectedProgram ? .isSelected : [])
    }
}
