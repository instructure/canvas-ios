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

struct CourseCardView: View {
    let course: CourseCardModel
    let onTapProgram: (CourseListWidgetModel.ProgramInfo) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            if course.hasPrograms {
                programLinkSection
            }

            Text(course.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.title)
                .multilineTextAlignment(.leading)
            progressbarView
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level3_5)
        .huiElevation(level: .level4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(course.accessibilityDescription)
    }

    private var programLinkSection: some View {
        ProgramNameListView(programs: course.programs) { program in
            onTapProgram(program)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressbarView: some View {
        HStack(spacing: .huiSpaces.space8) {
            HorizonUI.ProgressBar(
                progress: course.progress / 100.0,
                progressColor: .huiColors.surface.institution,
                size: .small,
                numberPosition: .hidden,
                backgroundColor: Color.huiColors.primitives.grey14
            )

            Text(course.progressPercentage)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.surface.institution)
        }
    }
}

#Preview {
    CourseCardView(
        course: .init(
            course: HCourse(
                id: "mock-course-id",
                name: "This is a mock course",
                state: HCourse.EnrollmentState.active.rawValue,
                progress: 40,
                currentLearningObject: nil,
                programs: [
                    Program(
                        id: "mock-program-id-1",
                        name: "This is a test program",
                        variant: "",
                        description: nil,
                        date: "",
                        courseCompletionCount: nil,
                        courses: [ProgramCourse(
                            id: "1",
                            isSelfEnrolled: false,
                            isRequired: false,
                            status: "",
                            progressID: "",
                            completionPercent: 0
                        )]
                    ),
                    Program(
                        id: "mock-program-id-2",
                        name: "This is a test program",
                        variant: "",
                        description: nil,
                        date: "",
                        courseCompletionCount: nil,
                        courses: [ProgramCourse(
                            id: "1",
                            isSelfEnrolled: false,
                            isRequired: false,
                            status: "",
                            progressID: "",
                            completionPercent: 0
                        )]
                    ),
                    Program(
                        id: "mock-program-id-3",
                        name: "This is a test program",
                        variant: "",
                        description: nil,
                        date: "",
                        courseCompletionCount: nil,
                        courses: [ProgramCourse(
                            id: "1",
                            isSelfEnrolled: false,
                            isRequired: false,
                            status: "",
                            progressID: "",
                            completionPercent: 0
                        )]
                    ),
                    Program(
                        id: "mock-program-id-4",
                        name: "This is a test program",
                        variant: "",
                        description: nil,
                        date: "",
                        courseCompletionCount: nil,
                        courses: [ProgramCourse(
                            id: "1",
                            isSelfEnrolled: false,
                            isRequired: false,
                            status: "",
                            progressID: "",
                            completionPercent: 0
                        )]
                    )
                ]
            )
        )
    ) { _ in }
        .padding()
}
