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

struct ProgramView: View {
    @State private var isProgramDropdownVisible: Bool = false
    @State private var programNameHeight: CGFloat?
    @Bindable var viewModel: LearnViewModel
    let isBackButtonVisible: Bool
    @Environment(\.viewController) private var viewController
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.isLoaderVisible {
                content
                    .padding([.horizontal, .bottom], .huiSpaces.space24)
            }
        }
        .padding(.top, .huiSpaces.space2)

        .toolbar(.hidden)
        .safeAreaInset(edge: .top, spacing: .huiSpaces.space24) {
            VStack(alignment: .leading, spacing: .zero) {
                navigationBar
                ExpandTitleView(title: viewModel.currentProgram?.name ?? "", isExpanded: isProgramDropdownVisible)
                    .padding(.top, isBackButtonVisible ? .huiSpaces.space10 : .huiSpaces.space24)
                    .padding(.horizontal, .huiSpaces.space24)
                    .hidden(viewModel.isLoaderVisible)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { isProgramDropdownVisible.toggle() }
                    .readingFrame { frame in programNameHeight = frame.height + ( isBackButtonVisible ? 45 : 0)  }
            }
        }
        .background(Color.huiColors.surface.pagePrimary)
        .onTapGesture { isProgramDropdownVisible = false }
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.top, .huiSpaces.space10)
                    .padding(.bottom, .huiSpaces.space4)
                    .background(Color.huiColors.surface.pagePrimary)
            }
        }
        .refreshable {
            await viewModel.refreshPrograms()
        }
        .huiToast(
            viewModel: .init(
                text: viewModel.toastMessage,
                style: viewModel.hasError ? .error : .success
            ),
            isPresented: $viewModel.toastIsPresented
        )
        .overlay(alignment: .top) {
            if isProgramDropdownVisible {
                ProgramSwitcherView(
                    isExpanded: $isProgramDropdownVisible,
                    programs: viewModel.dropdownMenuPrograms,
                    selectedProgram: viewModel.selectedProgram,
                    onSelectProgram: viewModel.onSelectProgram) { course in
                        viewModel.navigateToCourseDetails(
                            courseID: course?.id ?? "",
                            programID: course?.programID,
                            isEnrolled: course?.isEnrolled ?? false,
                            viewController: viewController
                        )
                    }
                    .padding(.top, programNameHeight)
                    .padding(.horizontal, .huiSpaces.space24)
            }
        }
        .animation(.linear, value: isProgramDropdownVisible)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if viewModel.shouldShowProgress {
                LearnProgressBarView(completionPercent: viewModel.currentProgram?.completionPercent)
                    .padding(.bottom, .huiSpaces.space8)
            }

            if let description = viewModel.currentProgram?.description {
                Text(description)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
                    .padding(.bottom, .huiSpaces.space16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            LearnAttributesView(
                estimatedDuration: viewModel.currentProgram?.estimatedTime,
                date: viewModel.currentProgram?.date
            )
            .padding(.bottom, viewModel.currentProgram?.hasPills == true ? .huiSpaces.space32 : .zero)

            if let program = viewModel.currentProgram, !program.isLinear, !program.isOptionalProgram {
                completeProgram(program)
                    .padding(.bottom, .huiSpaces.space16)
            }
            programCards
                .id(viewModel.currentProgram?.id)
                .padding(.top, .huiSpaces.space2)
        }
    }
    var programCards: some View {
        ListProgramCards(
            programs: viewModel.currentProgram?.courses ?? [],
            isLoading: viewModel.isLoadingEnrollButton, isLinear: viewModel.currentProgram?.isLinear ?? false
        ) { course in
            viewModel.navigateToCourseDetails(
                courseID: course.id,
                programID: viewModel.currentProgram?.id,
                isEnrolled: course.isEnrolled,
                viewController: viewController
            )
        } onTapEnroll: { course in
            viewModel.enrollInProgram(course: course )
        }
    }

    private func completeProgram(_ program: Program) -> some View {
        Text(
            String(
                format: String(localized: "Complete %d of %d courses", bundle: .horizon),
                viewModel.currentProgram?.countOfRemainingCourses ?? 0,
                viewModel.currentProgram?.courses.count ?? 0
            )
        )
        .foregroundStyle(Color.huiColors.text.body)
        .huiTypography(.h4)
    }

    @ViewBuilder
    private var navigationBar: some View {
        if isBackButtonVisible {
            HStack {
                Button {
                    viewModel.didTapBackButton(viewController: viewController)
                } label: {
                    Image.huiIcons.arrowBack
                        .foregroundStyle(Color.huiColors.icon.default)
                        .frame(width: 44, height: 44, alignment: .leading)

                }
                Spacer()
            }
            .padding(.horizontal, .huiSpaces.space24)
        }
    }
}

#if DEBUG
#Preview {
    ProgramView(
        viewModel: .init(
            interactor: ProgramInteractorPreview(),
            learnCoursesInteractor: GetLearnCoursesInteractorPreview(),
            router: AppEnvironment.shared.router,
            programID: nil
        ),
        isBackButtonVisible: false
    )
}
#endif
