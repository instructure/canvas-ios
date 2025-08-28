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
import SwiftUI
import HorizonUI

struct LearnView: View {
    @Bindable var viewModel: LearnViewModel
    @Environment(\.viewController) private var viewController
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.isLoaderVisible {
                content
                    .padding([.horizontal, .bottom], .huiSpaces.space24)
            }
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top, spacing: .zero) { LearnTopBar() }
        .background(Color.huiColors.surface.pagePrimary)
        .onFirstAppear { viewModel.featchPrograms() }
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
            programDropdown
                .padding(.bottom, .huiSpaces.space24)
                .id(viewModel.programs.count)

            if viewModel.shouldShowProgress {
                LearnProgressBar(completionPercent: viewModel.currentProgram?.completionPercent)
                    .padding(.bottom, .huiSpaces.space8)
            }

            if let description = viewModel.currentProgram?.description {
                Text(description)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
                    .padding(.bottom, .huiSpaces.space16)
            }

            LearnAttributesView(
                estimatedDuration: viewModel.currentProgram?.estimatedTime,
                date: viewModel.currentProgram?.date
            )
            .padding(.bottom, viewModel.currentProgram?.hasPills == true ? .huiSpaces.space32 : .zero)

            programCards
                .id(viewModel.currentProgram?.id)
        }
    }
}

// MARK: - Subviews
private extension LearnView {
    var programDropdown: some View {
        DropdownMenu(
            items: viewModel.dropdownMenuPrograms,
            selectedItem: viewModel.selectedProgram,
            onSelect: viewModel.onSelectProgram
        )
    }

    var programCards: some View {
        ListProgramCards(
            programs: viewModel.currentProgram?.courses ?? [],
            isLoading: viewModel.isLoadingEnrollButton, isLinear: viewModel.currentProgram?.isLinear ?? false
        ) { course in
            viewModel.navigateToCourseDetails(course: course, viewController: viewController)
        } onTapEnroll: { course in
            viewModel.enrollInProgram(course: course )
        }
    }

    private var pills: some View {
        HorizonUI.HFlow {
            defaultPill(title: "Program format")
            defaultPill(title: "6 hours 20 minutes")
            HorizonUI.Pill(
                title: "20/10/2025 - 20/10/2027",
                style: .solid(
                    .init(
                        backgroundColor: Color.huiColors.surface.pageSecondary,
                        textColor: Color.huiColors.text.title,
                        iconColor: Color.huiColors.icon.default
                    )
                ),
                isSmall: true,
                icon: .huiIcons.calendarToday
            )
        }
    }

    private func defaultPill(title: String) -> some View {
        HorizonUI.Pill(
            title: title,
            style: .solid(
                .init(
                    backgroundColor: Color.huiColors.surface.pageSecondary,
                    textColor: Color.huiColors.text.title
                )
            ),
            isSmall: true
        )
    }
}

// MARK: - ViewModel Helpers
private extension LearnViewModel {
    var shouldShowProgress: Bool {
        currentProgram?.isOptionalProgram == false
    }
}

#Preview {
    LearnView(
        viewModel: .init(
            interactor: ProgramInteractorLive(programCourseInteractor: ProgramCourseInteractorLive()),
            router: AppEnvironment.shared.router
        )
    )
}
