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

struct ProgramSwitcherView: View {
    // MARK: - Data

    private let programs: [ProgramSwitcherModel]
    private let onSelectProgram: (ProgramSwitcherModel?) -> Void
    private let onSelectCourse: (ProgramSwitcherModel.Course?) -> Void
    private let isProgramPage: Bool
    private let cornerRadius: HorizonUI.CornerRadius = .level2

    // MARK: - Bindings

    @Binding private var isExpanded: Bool

    // MARK: - State

    @State private var initialProgram: ProgramSwitcherModel?
    @State private var initialCourse: ProgramSwitcherModel.Course?
    @State private var selectedProgram: ProgramSwitcherModel?
    @State private var selectedCourse: ProgramSwitcherModel.Course?
    @State private var isCoursesViewVisible: Bool

    private var shouldHighlightProgram: Bool {
        initialCourse == nil && initialProgram == selectedProgram
    }

    // MARK: - Init

    init(
        isExpanded: Binding<Bool>,
        isProgramPage: Bool = true,
        programs: [ProgramSwitcherModel],
        selectedProgram: ProgramSwitcherModel? = nil,
        selectedCourse: ProgramSwitcherModel.Course? = nil,
        onSelectProgram: @escaping (ProgramSwitcherModel?) -> Void,
        onSelectCourse: @escaping (ProgramSwitcherModel.Course?) -> Void
    ) {
        self.programs = programs
        self.isProgramPage = isProgramPage
        self.onSelectProgram = onSelectProgram
        self.onSelectCourse = onSelectCourse
        self._isExpanded = isExpanded

        // State setup
        self._initialProgram = State(initialValue: selectedProgram)
        self._initialCourse = State(initialValue: selectedCourse)
        self._selectedProgram = State(initialValue: selectedProgram)
        self._selectedCourse = State(initialValue: selectedCourse)
        self._isCoursesViewVisible = State(initialValue: selectedProgram != nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let selectedProgram, isCoursesViewVisible {
                ProgramSwitcherHeaderView(
                    programName: selectedProgram.name ?? "",
                    shouldHighlightProgram: shouldHighlightProgram) {
                        isCoursesViewVisible = false
                    } onSelectOverview: {
                        initialCourse = nil
                        selectedCourse = nil
                        initialProgram = selectedProgram
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss(isSelectedProgram: true)
                        }
                    }

                coursesView(for: selectedProgram)
            } else {
                ProgramSwitcherListView(
                    programs: programs,
                    selectedProgram: selectedProgram,
                    selectedCourse: selectedCourse) { program in
                        selectedProgram = program
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isCoursesViewVisible = true
                        }
                    } onSelectCourse: { course in
                        selectedProgram = nil
                        initialProgram = nil
                        initialCourse = course
                        selectedCourse = course
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss(isSelectedProgram: false)
                        }
                    }
            }
        }
        .animation(.easeInOut, value: isCoursesViewVisible)
        .background(Color.huiColors.surface.cardPrimary)
        .clipShape(.rect(cornerRadius: cornerRadius.attributes.radius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius.attributes.radius)
                .stroke(Color.huiColors.lineAndBorders.containerStroke, lineWidth: 1)
                .opacity(isExpanded ? 1 : 0)
        )
    }

    private func dismiss(isSelectedProgram: Bool) {
        withAnimation {
            isExpanded = false
        } completion: {
            selectedProgram = initialProgram
            if isSelectedProgram {
                onSelectProgram(initialProgram)
            }
            onSelectCourse(selectedCourse)
            isCoursesViewVisible = true
        }
    }

    private func coursesView(for program: ProgramSwitcherModel) -> some View {
        ForEach(program.courses) { course in
            Button {
                selectedProgram = program
                initialCourse = course
                selectedCourse = course

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss(isSelectedProgram: false)
                }

            } label: {
                ProgramSwitcherCourseRowView(course: course, isSelected: course == selectedCourse)
            }
        }
    }
}
