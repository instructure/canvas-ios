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
    let model: LearnItemModel
    let onTapCourseDetails: () -> Void
    let onTapLearningObject: () -> Void

    var body: some View {
        contentView
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: .zero) {
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
                    onTapLearningObject()
                }
            }
            .padding([.horizontal, .bottom], .huiSpaces.space24)
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }

    private var courseDetailsButton: some View {
        Button {
            onTapCourseDetails()
        } label: {
            VStack(alignment: .leading, spacing: .huiSpaces.space16) {
                courseImage
                courseNameView
                coursePercentageView
                descriptionView
            }
        }
        .buttonStyle(.plain)
    }

    private var courseImage: some View {
        CourseImageView(url: model.imageUrl)
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
            progress: model.completionPercentage / 100.0,
            progressColor: .huiColors.surface.institution,
            size: .small,
            numberPosition: .outside,
            backgroundColor: Color.huiColors.primitives.grey14
        )
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var descriptionView: some View {
        HorizonUI.HFlow(spacing: .huiSpaces.space8, lineSpacing: .huiSpaces.space10) {
            HorizonUI.StatusChip(
                title: String(localized: "Course"),
                style: .institution,
                icon: Image.huiIcons.book2
            )

            if let estimatedTime = model.estimatedTime {
                HorizonUI.StatusChip(
                    title: estimatedTime,
                    style: .gray
                )
            }

            if let startAt = model.startAt, let endAt = model.endAt {
                HorizonUI.StatusChip(
                    title: String(format: "%@ - %@", startAt, endAt),
                    style: .gray,
                    icon: .huiIcons.calendarToday
                )
            }
        }
        .padding([.horizontal, .bottom], .huiSpaces.space24)
    }
}

#Preview {
    let model = LearnItemModel(
        id: "1",
        name: "Lo2rem Ipsum Course Name Here Dolor",
        completionPercentage: 0.4,
        position: 12,
        startAt: nil,
        endAt: nil,
        imageUrl: nil,
        estimatedDurationMinutes: 12,
        courseCount: 12,
        itemType: .course
    )
    LearnCourseCardView(model: model, onTapCourseDetails: { }, onTapLearningObject: {  })
        .padding()
}
