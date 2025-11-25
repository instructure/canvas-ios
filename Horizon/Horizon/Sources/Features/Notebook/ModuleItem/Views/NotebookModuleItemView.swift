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

struct NotebookModuleItemView: View {
    @AccessibilityFocusState private var focusedID: String?
    @State private var lastFocusedID: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController
    @State private var selectedNote: CourseNotebookNote?
    @State var viewModel: NotebookListViewModel

    var body: some View {
        VStack {
            navigationBar
            ScrollView(showsIndicators: false) {
                switch viewModel.state {
                case .data:
                    dataView
                default:
                    emptyView
                }
            }
        }
        .overlay { loaderView }
        .animation(.easeInOut, value: viewModel.listState.isNoteDeleted)
        .animation(.smooth, value: viewModel.filteredNotes.count)
        .huiToast(
            viewModel: .init(
                text: viewModel.listState.errorMessage,
                style: .error
            ),
            isPresented: $viewModel.listState.isPresentedErrorToast
        )
        .huiToast(
            viewModel: .init(
                text: viewModel.listState.successMessage,
                style: .success
            ),
            isPresented: $viewModel.listState.isPresentedSuccessToast
        )
        .onReceive(viewModel.listState.restoreAccessibility) {
            restoreFocusIfNeeded(after: 1)
        }

    }

    private var dataView: some View {
        NotesbookCardsView(
            notes: viewModel.filteredNotes,
            selectedNote: selectedNote,
            showDeleteLoader: viewModel.listState.isDeletedNoteLoaderVisible,
            isSeeMoreButtonVisible: viewModel.listState.isSeeMoreButtonVisible,
            screenType: .moduleItem,
            focusedID: $focusedID) { selectedNote in
                viewModel.presentEditNote(note: selectedNote, viewController: viewController)
                lastFocusedID = selectedNote.id
            } onTapDeleteNote: { deletedNote in
                selectedNote = deletedNote
                viewModel.deleteNote(deletedNote)
            } onTapSeeMore: {
                viewModel.seeMore()
            }
            .padding(.horizontal, .huiSpaces.space16)
            .padding(.top, .huiSpaces.space8)
            .accessibilityHint(String(localized: "Double tap to edit note", bundle: .horizon))
    }

    private var navigationBar: some View {
        VStack(spacing: .huiSpaces.space10) {
            HStack(spacing: .huiSpaces.space4) {
                Image.huiIcons.editNote
                    .foregroundStyle(Color.huiColors.icon.default)
                    .accessibilityHidden(true)
                Text("Notebook")
                    .foregroundStyle(Color.huiColors.text.title)
                    .huiTypography(.h4)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                HorizonUI.IconButton(
                    .huiIcons.close,
                    type: .darkOutline,
                    isSmall: true
                ) {
                    dismiss()
                }
                .accessibilityLabel(String(localized: "Double tap to dismiss the screen", bundle: .horizon))
            }
            .padding(.horizontal, .huiSpaces.space16)
            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .padding(.top, .huiSpaces.space16)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.listState.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
                    .accessibilityLabel("Loading Notebooks")
            }
        }
    }

    private var emptyView: some View {
        Text("To use the Notebook feature, highlight an excerpt from your learning material to flag it as “important” or “unclear,” and leave an optional note.")
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.p1)
            .padding(.huiSpaces.space16)
    }

    private func restoreFocusIfNeeded(after: Double = 1) {
        guard let lastFocused = lastFocusedID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedID = lastFocused
        }
    }
}

#if DEBUG
#Preview {
    NotebookModuleItemView(
        viewModel: .init(
            pageURL: "",
            courseID: "",
            interactor: CourseNoteInteractorPreview(),
            router: AppEnvironment.shared.router
        )
    )
}
#endif
