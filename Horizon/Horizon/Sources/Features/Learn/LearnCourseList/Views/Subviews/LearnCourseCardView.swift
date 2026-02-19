//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct LearnCourseCardView: View {
    let model: CourseListWidgetModel
    let width: CGFloat
    let onTapCourseDetails: () -> Void
    let onTapLearningObject: ((String, URL?) -> Void)?

    var body: some View {
        contentView
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            courseDetailsButton
                .accessibilityLabel(model.accessibilityLearnDescription)
            HorizonUI.PrimaryButton(
                model.buttonCourseTitle,
                type: .grayOutline,
                isSmall: false,
                fillsWidth: true
            ) {
                if model.isCourseCompleted {
                    onTapCourseDetails()
                } else {
                    onTapLearningObject?(model.id, model.currentLearningObject?.url)
                }
            }
            .padding([.horizontal, .bottom], .huiSpaces.space24)
        }

        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .scrollTransition(.animated) { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1 : 0.9)
        }
    }

    private var courseDetailsButton: some View {
        Button {
            onTapCourseDetails()
        } label: {
            VStack(alignment: .leading, spacing: .huiSpaces.space16) {
                courseImage
                courseNameView
                coursePercentageView
            }
        }
    }

    private var courseImage: some View {
        CourseImageView(
            width: width,
            url: model.imageURL
        )
    }

    private var courseNameView: some View {
        Text(model.name)
            .huiTypography(.labelLargeBold)
            .foregroundStyle(Color.huiColors.text.title)
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .huiSpaces.space24)
    }

    private var coursePercentageView: some View {
        HorizonUI.ProgressBar(
            progress: model.progress / 100.0,
            progressColor: .huiColors.surface.institution,
            size: .small,
            numberPosition: .outside,
            backgroundColor: Color.huiColors.primitives.grey14
        )
        .padding(.horizontal, .huiSpaces.space24)
    }
}

#Preview {
    let model = CourseListWidgetModel(
        id: "1",
        enrollmentID: "12",
        name: "Lo2rem Ipsum Course Name Here Dolor",
        imageURL: nil,
        progress: 25.0,
        lastActivityAt: nil,
        programs: [],
        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
            name: "Adipiscing Elit Learning Object Name Here",
            id: "122",
            moduleTitle: "Module Title",
            type: .assignment,
            dueDate: "Due XX/XX",
            estimatedDuration: "XX mins",
            url: nil
        )
    )
    LearnCourseCardView(model: model, width: 400, onTapCourseDetails: { }, onTapLearningObject: { _, _ in })
        .padding()
}
