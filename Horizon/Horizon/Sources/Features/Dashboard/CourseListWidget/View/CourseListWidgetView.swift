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

import Core
import HorizonUI
import SwiftUI

struct CourseListWidgetView: View {
    @State private var viewModel: CourseListWidgetViewModel
    @Environment(\.viewController) private var viewController

    @State private var currentCourseIndex: Int? = 0
    @State private var bounceScale: CGFloat = 1.0
    @State private var scrollViewID = UUID()

    init(viewModel: CourseListWidgetViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: .zero) {
            switch viewModel.state {
            case .data, .loading:
                programCardsView
                dataView
            case .empty:
                emptyView
            case .error:
                errorView
            }

            Spacer()
        }
        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: bounceScale)
        .onChange(of: viewModel.state) { oldValue, newValue in
            if oldValue == .loading && newValue == .data {
                currentCourseIndex = nil
                scrollViewID = UUID()
                bounceScale = 1.03
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    bounceScale = 1.0
                }
            }
        }
        .isSkeletonLoadActive(viewModel.state == .loading)
        .onWidgetReload { completion in
            viewModel.reload(completion: completion)
        }
    }

    private var dataView: some View {
        VStack(alignment: .center, spacing: .huiSpaces.space8) {
            SingleAxisGeometryReader(initialSize: 300) { size in
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: .huiSpaces.space12) {
                        ForEach(Array(viewModel.courses.enumerated()), id: \.element.id) { index, course in
                            CourseListWidgetItemView(
                                model: CourseListWidgetModel(from: course),
                                onCourseTap: { courseId in
                                    viewModel.navigateToCourseDetails(
                                        id: courseId,
                                        enrollmentID: course.enrollmentID,
                                        programID: course.programs.first?.id,
                                        viewController: viewController
                                    )
                                },
                                onProgramTap: { programId in
                                    viewModel.navigateProgram(id: programId, viewController: viewController)

                                },
                                onLearningObjectTap: { _, url in
                                    if let url = url,
                                       let currentLearningObject = course.currentLearningObject {
                                        viewModel.navigateToItemSequence(
                                            url: url,
                                            learningObject: currentLearningObject,
                                            viewController: viewController
                                        )
                                    }
                                }
                            )
                            .frame(width: size - 48)
                            .scaleEffect(bounceScale)
                            .opacity(viewModel.state == .loading ? 0.6 : 1.0)
                            .scrollTransition(.interactive) { content, phase in
                                content
                                    .scaleEffect(y: phase.isIdentity ? 1.0 : 0.8)
                            }
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, .huiSpaces.space24)
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
                .scrollPosition(id: $currentCourseIndex)
                .id(scrollViewID)
            }

            if viewModel.courses.count > 1 {
                PaginationIndicatorView(currentIndex: $currentCourseIndex, count: viewModel.courses.count)
            }
        }
    }

    @ViewBuilder
    private var programCardsView: some View {
        if viewModel.unenrolledPrograms.isNotEmpty, viewModel.state == .data {
            UnenrolledProgramListWidgetView(programs: viewModel.unenrolledPrograms) { program in
                viewModel.navigateProgram(id: program.id, viewController: viewController)
            }
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.bottom, .huiSpaces.space16)
        }
    }

    private var errorView: some View {
        CourseListWidgetErrorView {
            viewModel.reload(completion: nil)
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var emptyView: some View {
        CourseListWidgetEmptyView()
            .padding(.horizontal, .huiSpaces.space24)
    }
}
