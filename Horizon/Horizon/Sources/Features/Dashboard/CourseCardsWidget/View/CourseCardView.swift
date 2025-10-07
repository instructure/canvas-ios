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
    let model: CourseCardModel
    let onCourseTap: (String) -> Void
    let onProgramTap: ((String) -> Void)?
    let onLearningObjectTap: ((String, URL?) -> Void)?

    private let imageHeight: CGFloat = 182

    var body: some View {
        VStack(spacing: .zero) {
            courseImageSection
            courseContentSection
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .onTapGesture {
            onCourseTap(model.id)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to open course")
        .accessibilityIdentifier("CourseCard.\(model.id)")
        .accessibilityActions {
            if let primaryProgram = model.primaryProgram {
                Button("View \(primaryProgram.name) program") {
                    onProgramTap?(primaryProgram.id)
                }
            }

            if model.hasCurrentLearningObject {
                Button("Continue learning") {
                    onLearningObjectTap?(model.id, model.currentLearningObject?.url)
                }
            }
        }
        .id(model.id)
    }

    private var courseImageSection: some View {
        SkeletonAsyncImage(
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
                .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        } placeholder: {
            Color.huiColors.primitives.grey14
                .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        }
        .skeletonLoadable()
        .frame(height: imageHeight)
        .padding(.bottom, .huiSpaces.space16)
    }

    private var courseContentSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            if model.hasPrograms {
                programLinkSection
            }

            courseTitleAndProgressSection

            if model.hasCurrentLearningObject {
                learningObjectSection
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
                .huiTypography(.h3)
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
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                HStack {
                    Text(model.progressPercentage)
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.title)
                    Spacer()
                }
                .skeletonLoadable()

                HorizonUI.ProgressBar(
                    progress: model.progress / 100.0,
                    progressColor: .huiColors.surface.institution,
                    size: .small,
                    numberPosition: .hidden,
                    backgroundColor: Color.huiColors.primitives.grey14
                )
                .skeletonLoadable()
            }
            if !model.hasCurrentLearningObject {
                Text("Congrats! You’ve completed your course. View your progress and scores on the Learn page.")
                    .huiTypography(.p1)
                    .foregroundColor(.huiColors.text.title)
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
            .buttonStyle(.plain)
        }
    }

    private func learningObjectMetadata(for learningObject: CourseCardModel.LearningObjectInfo) -> some View {
        HorizonUI.WrappingHStack(spacing: .huiSpaces.space8) {
            if let type = learningObject.type {
                HorizonUI.Pill(
                    title: type.rawValue,
                    style: .solid(
                        .init(
                            backgroundColor: Color.huiColors.surface.pageSecondary,
                            textColor: Color.huiColors.text.body,
                            iconColor: Color.huiColors.icon.default
                        )
                    ),
                    isSmall: true,
                    icon: type.getIcon(isAssessment: false)
                )
                .skeletonLoadable()
            }

            if let dueDate = learningObject.dueDate {
                HorizonUI.Pill(
                    title: dueDate,
                    style: .solid(
                        .init(
                            backgroundColor: Color.huiColors.surface.pageSecondary,
                            textColor: Color.huiColors.text.body,
                            iconColor: Color.huiColors.icon.default
                        )
                    ),
                    isSmall: true,
                    icon: .huiIcons.calendarToday
                )
                .skeletonLoadable()
            }

            if let duration = learningObject.estimatedDuration {
                HorizonUI.Pill(
                    title: duration,
                    style: .solid(
                        .init(
                            backgroundColor: Color.huiColors.surface.pageSecondary,
                            textColor: Color.huiColors.text.body,
                            iconColor: Color.huiColors.icon.default
                        )
                    ),
                    isSmall: true,
                    icon: .huiIcons.schedule
                )
                .skeletonLoadable()
            }
            Spacer()
        }
    }

    private var accessibilityDescription: String {
        var description = "Course: \(model.name). Progress: \(model.progressPercentage)."

        if let program = model.primaryProgram {
            description += " Part of \(program.name)."
        }

        if let learningObject = model.currentLearningObject {
            description += " Current learning object: \(learningObject.name)."

            if let dueDate = learningObject.dueDate {
                description += " Due \(dueDate)."
            }
        }

        return description
    }
}

#if DEBUG
    #Preview {
        ScrollView {
            VStack {
                CourseCardView(
                    model: CourseCardModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseCardModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: "xxxxx",
                            estimatedDuration: "xxxxx",
                            url: nil
                        )
                    ),
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                .isSkeletonLoadActive(true)

                CourseCardView(
                    model: CourseCardModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here Dolor",
                        imageURL: nil,
                        progress: 25.0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseCardModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assignment,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseCardView(
                    model: CourseCardModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here Dolor Sit Amet Adipising Elit So",
                        imageURL: nil,
                        progress: 25.0,
                        lastActivityAt: nil,
                        programs: [
                            CourseCardModel.ProgramInfo(id: "1", name: "Program Name Here"),
                            CourseCardModel.ProgramInfo(id: "2", name: "Another Program"),
                            CourseCardModel.ProgramInfo(id: "3", name: "And an other one")

                        ],
                        currentLearningObject: CourseCardModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .page,
                            dueDate: "Due XX/XX",
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseCardView(
                    model: CourseCardModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: CourseCardModel.LearningObjectInfo(
                            name: "Adipiscing Elit Learning Object Name Here",
                            moduleTitle: "Module Title",
                            type: .assessment,
                            dueDate: nil,
                            estimatedDuration: "XX mins",
                            url: nil
                        )
                    ),
                    onCourseTap: { _ in },
                    onProgramTap: { _ in },
                    onLearningObjectTap: { _, _ in }
                )
                .padding()
                CourseCardView(
                    model: CourseCardModel(
                        id: "1",
                        name: "Lo2rem Ipsum Course Name Here",
                        imageURL: nil,
                        progress: 0,
                        lastActivityAt: nil,
                        programs: [],
                        currentLearningObject: nil
                    ),
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
