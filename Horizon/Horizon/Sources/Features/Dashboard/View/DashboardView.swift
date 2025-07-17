//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct DashboardView: View {
    @Bindable private var viewModel: DashboardViewModel
    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.state == .data {
                invitedCoursesView
            }
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(
                    refreshable: true,
                    loaderBackgroundColor: .huiColors.surface.pagePrimary
                ),
                refreshAction: viewModel.reload
            ) { _ in
                VStack(spacing: .zero) {
                    if viewModel.courses.isEmpty, viewModel.state == .data {
                        Text("You aren’t currently enrolled in a course.", bundle: .horizon)
                            .padding(.huiSpaces.space24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.huiColors.text.body)
                            .huiTypography(.h3)

                    } else {
                        topView
                        contentView(courses: viewModel.courses)
                            .padding(.bottom, .huiSpaces.space16)
                    }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: .zero) {
            if isShowHeader {
                navigationBar
                    .toolbar(.hidden)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Rectangle()
                    .fill(Color.huiColors.surface.pagePrimary)
                    .frame(height: 55)
                    .ignoresSafeArea()
            }
        }
        .scrollIndicators(.hidden, axes: .vertical)
        .background(Color.huiColors.surface.pagePrimary)
        .animation(.smooth, value: viewModel.invitedCourses)
        .animation(.linear, value: isShowHeader)
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text("Something went wrong", bundle: .horizon), message: Text(viewModel.errorMessage))
        }
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
            }
    }

    private func contentView(courses: [HCourse]) -> some View {
        ForEach(courses) { course in
            VStack(alignment: .leading, spacing: .zero) {
                courseProgressionView(course: course)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.navigateToCourseDetails(
                            id: course.id,
                            enrollmentID: course.enrollmentID,
                            viewController: viewController
                        )
                    }

                if let learningObjectCardModel = course.learningObjectCardModel {
                    learningObjectCard(model: learningObjectCardModel, progress: course.progress)
                        .padding(.bottom, .huiSpaces.space16)
                } else {
                    Text("Congrats! You've completed your course.", bundle: .horizon)
                        .huiTypography(.h3)
                        .foregroundStyle(Color.huiColors.text.title)
                        .padding(.top, .huiSpaces.space32)
                    Text("View your progress and scores on the Learn page.", bundle: .horizon)
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.title)
                        .padding(.top, .huiSpaces.space12)
                }
            }
            .padding(.horizontal, .huiSpaces.space24)
        }
    }

    private func courseProgressionView(course: HCourse) -> some View {
        Group {
            Text(course.name)
                .huiTypography(.h1)
                .foregroundStyle(Color.huiColors.text.title)
                .padding(.top, .huiSpaces.space16)
                .padding(.bottom, .huiSpaces.space16)

            HorizonUI.ProgressBar(
                progress: course.progress / 100.0,
                size: .medium,
                numberPosition: .outside
            )
        }
    }

    private func learningObjectCard(model: HCourse.LearningObjectCard, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("Resume Learning", bundle: .horizon)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .padding(.top, .huiSpaces.space36)
                .padding(.bottom, .huiSpaces.space12)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                if let url = model.url {
                    viewModel.navigateToItemSequence(url: url, viewController: viewController)
                }
            } label: {
                HorizonUI.LearningObjectCard(
                    status: viewModel.getStatus(percent: progress),
                    moduleTitle: model.moduleTitle,
                    learningObjectName: model.learningObjectName,
                    duration: model.estimatedTime,
                    type: model.type?.rawValue,
                    dueDate: model.dueDate,
                    icon: model.type?.getIcon(isAssessment: model.isNewQuiz)
                )
            }
        }
    }

    private var navigationBar: some View {
        HStack(spacing: .zero) {
            InstitutionLogo()
            Spacer()
            HorizonUI.NavigationBar.Trailing {
                viewModel.notebookDidTap(viewController: viewController)
            } onNotificationDidTap: {
                viewModel.notificationsDidTap(viewController: viewController)
            } onMailDidTap: {
                viewModel.mailDidTap(viewController: viewController)
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space10)
        .padding(.bottom, .huiSpaces.space4)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var invitedCoursesView: some View {
        ForEach(viewModel.invitedCourses) { course in
            HorizonUI
                .Toast(
                    viewModel: .init(
                        text: course.name,
                        style: .info,
                        dismissAfter: nil,
                        confirmActionButton: .init(
                            title: String(localized: "Accept", bundle: .horizon),
                            action: {  viewModel.acceptInvitation(course: course) })
                    )) { viewModel.declineInvitation(course: course) }
                .padding(.bottom, .huiSpaces.space12)
        }
    }
}

#if DEBUG
#Preview {
    DashboardAssembly.makePreview()
}
#endif
