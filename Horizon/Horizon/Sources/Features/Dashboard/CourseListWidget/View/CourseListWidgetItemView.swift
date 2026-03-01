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
    let currentIndex: Int
    let totalCount: Int
    let onCourseTap: (String) -> Void
    let onProgramTap: ((String) -> Void)?
    let onLearningObjectTap: ((String, URL?) -> Void)?
    private let isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
    private let imageHeight: CGFloat = 182

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                ZStack(alignment: .topLeading) {
                    courseImageSection
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onCourseTap(model.id)
                        }
                    if model.hasPrograms {
                        programLinkSection

                    }
                }

                courseContentSection
                Spacer()
                counterView

            }
            voiceOverHelperView
        }
        .padding(.bottom, .huiSpaces.space16)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(model.accessibilityHintString)
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

    private var accessibilityLabel: String {
        var label = model.accessibilityDescription
        if totalCount > 1 {
            label += String(
                format: String(localized: "%d of %d"),
                currentIndex + 1,
                totalCount
            )
        }
        return label
    }

    private func onCardTapGesture() {
        if model.hasCurrentLearningObject {
            onLearningObjectTap?(model.id, model.currentLearningObject?.url)
        } else {
            onCourseTap(model.id)
        }
    }

    private var courseImageSection: some View {
        CourseImageView(
            height: imageHeight,
            width: width,
            url: model.imageURL
        )
        .padding(.bottom, .huiSpaces.space16)
    }

    private var courseContentSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
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
    }

    private var programLinkSection: some View {
        ProgramNameListChipView(programs: model.programs) { program in
            onProgramTap?(program.id)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .skeletonLoadable()
        .padding(.huiSpaces.space24)
    }

    private var courseTitleAndProgressSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text(model.name)
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.title)
                .lineLimit(1)
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
            .padding(.vertical, .huiSpaces.space8)
            if model.isCourseCompleted {
                Text("Congrats! You’ve completed your course. View your progress and scores on the Learn page.")
                    .huiTypography(.p1)
                    .foregroundColor(.huiColors.text.title)
                    .padding(.top, .huiSpaces.space16)
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
                    Text(learningObject.name)
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.body)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            HStack(spacing: .huiSpaces.space8) {
                if let estimatedDuration = learningObject.estimatedDuration {
                    HorizonUI.StatusChip(
                        title: estimatedDuration,
                        style: .white,
                        icon: .huiIcons.schedule,
                        isFilled: true
                    )
                    .skeletonLoadable()
                    .accessibilityHidden(true)
                }

                HorizonUI.StatusChip(
                    title: learningObject.dueDate ?? String(localized: "No due date"),
                    style: .white,
                    icon: .huiIcons.calendarToday,
                    isFilled: true
                )
                .skeletonLoadable()
                .accessibilityHidden(true)
            }

            HorizonUI.StatusChip(
                title: (learningObject.type ?? .assessment).rawValue,
                style: .white,
                icon: (learningObject.type ?? .assessment).getIcon(isAssessment: false),
                isFilled: true
            )
            .skeletonLoadable()
            .accessibilityHidden(true)
            .hidden((learningObject.type == nil))
        }
    }

    @ViewBuilder
    private var voiceOverHelperView: some View {
        if isVoiceOverRunning {
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
    }

    @ViewBuilder
    private var counterView: some View {
        if totalCount > 1 {
            CounterTextView(
                currentIndex: currentIndex + 1,
                totalCount: totalCount
            )
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
                        enrollmentID: "12",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            id: "2121",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: "xxxxx",
                            estimatedDuration: "xxxxx",
                            url: nil
                        )
                    ),
                    width: 300,
                    currentIndex: 1,
                    totalCount: 10,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                .isSkeletonLoadActive(true)

                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        enrollmentID: "444",
                        name: "Lo2rem Ipsum Course Name Here Dolor",
                        imageURL: nil,
                        progress: 25.0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            id: "3232",
                            moduleTitle: "Module Title",
                            type: .assignment,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    width: 300,
                    currentIndex: 2,
                    totalCount: 10,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        enrollmentID: "4444",
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
                            id: "909",
                            moduleTitle: "Module Title",
                            type: .page,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    width: 300,
                    currentIndex: 3,
                    totalCount: 10,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        enrollmentID: "566",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseListWidgetModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            id: "66",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: nil,
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    width: 300,
                    currentIndex: 3,
                    totalCount: 10,
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseListWidgetItemView(
                    model: CourseListWidgetModel(
                        id: "1",
                        enrollmentID: "5454",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: nil
                    ),
                    width: 300,
                    currentIndex: 3,
                    totalCount: 10,
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
