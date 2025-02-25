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

import SwiftUI
import Core
import HorizonUI

struct NotebookView: View {

    @Bindable var viewModel: NotebookViewModel
    @Environment(\.viewController) private var viewController

    private let navigationBarViewModel: NavigationBarViewModel = .init()

    var body: some View {
        NavigationBarView(
            state: viewModel.state,
            viewModel: navigationBarViewModel,
            refreshable: false
        ) {
            VStack {
                HStack {
                    backButton

                    title

                    addNoteButton
                }
                ZStack {
                    if viewModel.isEmptyCardVisible {
                        emptyCard
                    } else {
                        VStack {
                            notesBody
                            forwardBackButtons
                        }
                    }
                }
            }
            .padding(.all, .huiSpaces.space16)
        }
    }

    private var addNoteButton: some View {
        HorizonUI.IconButton(
            .huiIcons.add,
            type: .white
        ) {
            viewModel.onAdd(viewController: viewController)
        }
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
            NotebookSectionHeading(title: String(localized: "Filter", bundle: .horizon))

            HStack(spacing: .huiSpaces.space16) {
                NoteCardFilterButton(type: .confusing, selected: viewModel.isConfusingEnabled)
                    .onTapGesture {
                        viewModel.filter = .confusing
                    }
                NoteCardFilterButton(type: .important, selected: viewModel.isImportantEnabled)
                    .onTapGesture {
                        viewModel.filter = .important
                    }
            }
            .frame(maxWidth: .infinity)

            NotebookSectionHeading(title: String(localized: "Notes", bundle: .horizon))

            ForEach(viewModel.notes) { note in
                NoteCardView(note: note)
                    .onTapGesture {
                        viewModel.onNoteTapped(note, viewController: viewController)
                    }
            }
        }
    }

    private var emptyCard: some View {
        HorizonUI.Card {
            Text("This is where all your notes, taken directly within your learning objects, are stored and organized. It's your personal hub for keeping track of key insights, important excerpts, and reflections as you learn. Dive in to review or expand on your notes anytime!",
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
    NotebookView(viewModel: .init())
}
