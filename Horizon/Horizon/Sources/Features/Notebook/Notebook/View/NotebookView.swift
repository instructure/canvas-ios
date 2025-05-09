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

struct NotebookView: View {

    @Bindable var viewModel: NotebookViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        if viewModel.isNavigationBarVisible {
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(
                    refreshable: true,
                    loaderBackgroundColor: HorizonUI.colors.surface.pagePrimary
                ),
                refreshAction: viewModel.refresh
            ) { _ in
                content
                    .padding(.all, .huiSpaces.space16)
            }
            .background(HorizonUI.colors.surface.pagePrimary)
            .frame(maxHeight: .infinity)
            .toolbar(.hidden)
            .safeAreaInset(edge: .top, spacing: .zero) {
                navigationBar
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack {
            ZStack {
                if viewModel.isEmptyCardVisible {
                    emptyCard
                } else {
                    VStack {
                        filterButtons
                        notesBody
                        forwardBackButtons
                    }
                }
            }
        }
        .padding(.bottom, .huiSpaces.space16)
    }

    @ViewBuilder
    private var forwardBackButtons: some View {
        if viewModel.isPaginationButtonsVisible {
            HStack {
                HorizonUI.IconButton(
                    .huiIcons.chevronLeft,
                    type: .black,
                    isSmall: true
                ) {
                    viewModel.previousPage()
                }
                .disabled(viewModel.isPreviousDisabled)
                HorizonUI.IconButton(
                    .huiIcons.chevronRight,
                    type: .black,
                    isSmall: true
                ) {
                    viewModel.nextPage()
                }
                .disabled(viewModel.isNextDisabled)
            }
            .padding(.top, .huiSpaces.space24)
        }
    }

    private var navigationBar: some View {
        TitleBar(
            onBack: viewModel.isBackVisible ? viewModel.onBack : nil,
            onClose: viewModel.isCloseVisible ? viewModel.onClose : nil
        ) {
            NotebookTitle()
        }
        .padding(.top, viewModel.navigationBarTopPadding)
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space16)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var notesBody: some View {
        VStack(spacing: .huiSpaces.space12) {
            NotebookSectionHeading(title: String(localized: "Notes", bundle: .horizon))
            ForEach(viewModel.notes) { note in
                NoteCardView(note: note)
                .onTapGesture {
                    viewModel.goToModuleItem(note, viewController: viewController)
                }
            }
        }
    }

    @ViewBuilder
    private var filterButtons: some View {
        if viewModel.isFiltersVisible {
            NotebookSectionHeading(title: String(localized: "Filter", bundle: .horizon))
                .padding(.top, .huiSpaces.space24)
            HStack(spacing: .huiSpaces.space12) {
                ForEach(viewModel.courseNoteLabels, id: \.rawValue) { filter in
                    NoteCardFilterButton(type: filter, selected: viewModel.isEnabled(filter: filter))
                        .onTapGesture {
                            viewModel.filter = filter
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var emptyCard: some View {
        HorizonUI.Card {
            Text(
                // swiftlint:disable:next line_length
                "This is where all your notes, taken directly within your learning objects, are stored and organized. It's your personal hub for keeping track of key insights, important excerpts, and reflections as you learn. Dive in to review or expand on your notes anytime!",
                bundle: .horizon
            )
            .huiTypography(.p1)
        }
        .padding(.horizontal, viewModel.isNavigationBarVisible ? .huiSpaces.space24 : 0)
        .padding(.vertical, viewModel.isNavigationBarVisible ? .huiSpaces.space32 : 0)
    }
}

#if DEBUG
#Preview {
    NotebookView(
        viewModel: .init(
            courseId: "123",
            courseNoteInteractor: CourseNoteInteractorPreview()
        ))
}
#endif
