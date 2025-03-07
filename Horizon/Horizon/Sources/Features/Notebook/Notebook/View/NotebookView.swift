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
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: false,
                loaderBackgroundColor: HorizonUI.colors.surface.pagePrimary
            )
        ) { _ in
            VStack {
                HStack {
                    backButton
                    title
                    backButton.hidden()
                }
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
            .padding(.all, .huiSpaces.space16)
        }
        .navigationBarHidden(true)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var backButton: some View {
        HorizonUI.IconButton(
            .huiIcons.arrowBack,
            type: .white
        ) {
            viewModel.onBack(viewController: viewController)
        }
    }

    private var forwardBackButtons: some View {
        HStack {
            HorizonUI.IconButton(
                .huiIcons.chevronLeft,
                type: .black
            ) {
                viewModel.previousPage()
            }
            .disabled(viewModel.isPreviousDisabled)

            HorizonUI.IconButton(
                .huiIcons.chevronRight,
                type: .black
            ) {
                viewModel.nextPage()
            }
            .disabled(viewModel.isNextDisabled)
        }
        .padding(.top, .huiSpaces.space24)
    }

    private var notesBody: some View {
        VStack {
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
        NotebookSectionHeading(title: String(localized: "Filter", bundle: .horizon))

        HStack(spacing: .huiSpaces.space16) {
            ForEach(viewModel.courseNoteLabels, id: \.rawValue) { filter in
                NoteCardFilterButton(type: filter, selected: viewModel.isEnabled(filter: filter))
                    .onTapGesture {
                        viewModel.filter = filter
                    }
            }
        }
        .frame(maxWidth: .infinity)
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
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.vertical, .huiSpaces.space32)
    }

    private var title: some View {
        Text("Notebook", bundle: .horizon)
            .frame(maxWidth: .infinity)
            .huiTypography(.h3)
    }
}

#Preview {
    NotebookView(
        viewModel: .init(
            getCourseNotesInteractor: GetCourseNotesInteractorPreview()
        ))
}
