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

struct ProgramDetailsView: View {
    // MARK: - Propertites
    @AccessibilityFocusState private var focusedItemID: String?
    @State private var lastFocusedID: String?

    @State var viewModel: ProgramDetailsViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.isLoaderVisible {
                content
                    .padding([.horizontal, .bottom], .huiSpaces.space24)
                    .onAppear {
                        if let lastFocusedID {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focusedItemID = lastFocusedID
                            }
                        }
                    }
            }
        }
        .padding(.top, .huiSpaces.space2)
        .onFirstAppear { viewModel.fetchPrograms() }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top, spacing: .huiSpaces.space8) { navigationBar }
        .background(Color.huiColors.surface.pagePrimary)
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
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.currentProgram?.name ?? "")
                    .huiTypography(.h3)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color.huiColors.text.title)
                    .padding(.bottom, .huiSpaces.space16)

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
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(viewModel.currentProgram?.accessibilityDescription)
            programCards
                .id(viewModel.currentProgram?.id)
                .padding(.top, .huiSpaces.space2)
        }
    }
    var programCards: some View {
        ListProgramCards(
            programs: viewModel.currentProgram?.courses ?? [],
            isLoading: viewModel.isLoadingEnrollButton, isLinear: viewModel.currentProgram?.isLinear ?? false,
            focusedID: $focusedItemID
        ) { course in
            lastFocusedID = course.id
            viewModel.navigateToCourseDetails(
                courseID: course.id,
                programName: viewModel.currentProgram?.name,
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

    private var navigationBar: some View {
        HStack {
            HorizonBackButton { _ in
                viewModel.didTapBackButton(viewController: viewController)
            }
            Spacer()
        }
        .padding(.horizontal, .huiSpaces.space24)
    }
}

#if DEBUG
#Preview {
    ProgramDetailsView(
        viewModel: .init(
            interactor: ProgramInteractorPreview(),
            learnCoursesInteractor: GetLearnCoursesInteractorPreview(),
            router: AppEnvironment.shared.router,
            programID: "1"
        )
    )
}
#endif
