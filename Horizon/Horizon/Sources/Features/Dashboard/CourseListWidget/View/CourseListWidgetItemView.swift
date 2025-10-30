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

struct CourseListWidgetItemView: View {
    let model: CourseListWidgetModel
    let width: CGFloat
    let onCourseTap: (String) -> Void
    let onProgramTap: ((String) -> Void)?
    let onLearningObjectTap: ((String, URL?) -> Void)?

    private let imageHeight: CGFloat = 182

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                courseImageSection
                courseContentSection
            }
            .onTapGesture {
                onCardTapGesture()
            }

            Color.clear // This is needed to overwrite a11y VO automatic tap gesture mechanism.
                .frame(height: imageHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    if model.id != "mock-course-id" { // This is mock data for skeleton loading so we disable user interaction.
                        onCourseTap(model.id)
                    }
                }
                .allowsHitTesting(true)
                .accessibilityHidden(true)
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityDescription)
        .accessibilityHint(model.accessiblityHintString)
        .accessibilityAction {
            onCardTapGesture()
        }
        .accessibilityActions {
            if model.id != "mock-course-id" {
                Button("Open course") {
                    onCourseTap(model.id)
                }

                ForEach(model.programs) { program in
                    Button {
                        onProgramTap?(program.id)
                    } label: {
                        Text(model.viewProgramAccessibilityString(program.name))
                    }
                }

                if model.hasCurrentLearningObject {
                    Button("Open learning object") {
                        onLearningObjectTap?(model.id, model.currentLearningObject?.url)
                    }
                }
            }
        }
        .id(model.id)
    }

    private func onCardTapGesture() {
        if model.hasCurrentLearningObject {
            onLearningObjectTap?(model.id, model.currentLearningObject?.url)
        } else {
            onCourseTap(model.id)
        }
    }

    private var courseImageSection: some View {
        SkeletonRemoteImage(
            url: model.imageURL,
            topLeading: 32,
            topTrailing: 32,
            bottomLeading: 0,
            bottomTrailing: 0
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight)
                .frame(maxWidth: width)
                .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
                .accessibilityLabel("")
                .accessibilityRemoveTraits(.isImage)
                .accessibilityHidden(true)
        } placeholder: {
            ZStack {
                Color.huiColors.primitives.grey14
                    .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
                    .accessibilityHidden(true)
                Image.huiIcons.book2Filled
                    .foregroundStyle(Color.huiColors.surface.institution)
                    .accessibilityHidden(true)
            }
        }
        .skeletonLoadable()
        .frame(height: imageHeight)
        .padding(.bottom, .huiSpaces.space16)
        .accessibilityLabel("")
        .accessibilityRemoveTraits(.isImage)
        .accessibilityHidden(true)
    }

    private var courseContentSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            if model.hasPrograms {
                programLinkSection
            }

            courseTitleAndProgressSection
                .onTapGesture {
                    onCourseTap(model.id)
                }

            if model.hasCurrentLearningObject {
                learningObjectSection
                    .onTapGesture {
                        onLearningObjectTap?(model.id, model.currentLearningObject?.url)
                    }
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.bottom, .huiSpaces.space24)
    }

    private var programLinkSection: some View {
        ProgramNameListView(programs: model.programs) { program in
            onProgramTap?(program.id)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skeletonLoadable()
    }

    private var courseTitleAndProgressSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text(model.name)
                .huiTypography(.h4)
                .foregroundStyle(Color.huiColors.text.title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .skeletonLoadable()
            progressSection
        }
    }

    private var progressSection: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack(spacing: .huiSpaces.space8) {
                HorizonUI.ProgressBar(
                    progress: model.progress / 100.0,
                    progressColor: .huiColors.surface.institution,
                    size: .small,
                    numberPosition: .hidden,
                    backgroundColor: Color.huiColors.primitives.grey14
                )
                .skeletonLoadable()

                Text(model.progressPercentage)
                    .huiTypography(.p2)
                    .foregroundStyle(Color.huiColors.surface.institution)
                    .skeletonLoadable()
            }
            if model.isCourseCompleted {
                Text("Congrats! You’ve completed your course. View your progress and scores on the Learn page.")
                    .huiTypography(.p1)
                    .foregroundColor(.huiColors.text.title)
            } else {
                Text("No modules found")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .huiTypography(.p1)
                    .foregroundColor(.huiColors.text.title)
                    .skeletonLoadable()
            }
        }
    }

    @ViewBuilder
    private var learningObjectSection: some View {
        if let learningObject = model.currentLearningObject {
            Button {
                onLearningObjectTap?(model.id, learningObject.url)
            } label: {
                VStack(alignment: .leading, spacing: .huiSpaces.space12) {
                    HStack {
                        Text(learningObject.name)
                            .huiTypography(.p2)
                            .foregroundStyle(Color.huiColors.text.body)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .skeletonLoadable()

                    learningObjectMetadata(for: learningObject)
                }
                .padding(.huiSpaces.space16)
                .background(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .fill(Color.huiColors.surface.institution.opacity(0.1))
                )
            }
            .accessibilityHidden(true)
            .accessibilityRemoveTraits(.isButton)
            .buttonStyle(.plain)
        }
    }

    private func learningObjectMetadata(for learningObject: CourseListWidgetModel.LearningObjectInfo) -> some View {
        HorizonUI.WrappingHStack(spacing: .huiSpaces.space8) {
            if let type = learningObject.type {
                HorizonUI.StatusChip(
                    title: type.rawValue,
                    style: .white,
                    icon: type.getIcon(isAssessment: false),
                    isFilled: true
                )
                .skeletonLoadable()
                .accessibilityHidden(true)
            }

            if let dueDate = learningObject.dueDate {
                HorizonUI.StatusChip(
                    title: dueDate,
                    style: .white,
                    icon: .huiIcons.calendarToday,
                    isFilled: true
                )
                .skeletonLoadable()
                .accessibilityHidden(true)
            }

            if let duration = learningObject.estimatedDuration {
                HorizonUI.StatusChip(
                    title: duration,
                    style: .white,
                    icon: .huiIcons.schedule,
                    isFilled: true
                )
                .skeletonLoadable()
                .accessibilityHidden(true)
            }
            Spacer()
        }
    }
}

#if DEBUG
    #Preview {
        ScrollView {
            VStack {
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: "xxxxx",
                            estimatedDuration: "xxxxx",
                            url: nil
                        )
                    ), width: 300,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                .isSkeletonLoadActive(true)

                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here Dolor",
                        imageURL: nil,
                        progress: 25.0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assignment,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ), width: 300,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here Dolor Sit Amet Adipising Elit So",
                        imageURL: nil,
                        progress: 25.0,
                        lastActivityAt: nil,
                        programs: [
                            CourseListWidgetModel.ProgramInfo(id: "1", name: "Program Name Here"),
                            CourseListWidgetModel.ProgramInfo(id: "2", name: "Another Program"),
                            CourseListWidgetModel.ProgramInfo(id: "3", name: "And an other one")

                        ],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .page,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ), width: 300,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: nil,
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ), width: 300,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: nil
                    ), width: 300,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
            }
        }
        .background(Color.huiColors.surface.pagePrimary)
    }
#endif
