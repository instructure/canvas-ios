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

struct NotebookCourseView: View {
    // MARK: - A11y Properties

    @AccessibilityFocusState private var focusedID: String?
    @State private var lastFocusedID: String?
    private let selectLabelFocusedID = "selectLabelFocusedID"

    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController
    @State private var selectedNote: CourseNotebookNote?
    @State var viewModel: NotebookListViewModel

    var body: some View {
        contentView
            .overlay { loaderView }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level4, corners: [.topLeft, .topRight])
            .animation(.easeInOut, value: viewModel.listState.isNoteDeleted)
            .animation(.smooth, value: viewModel.filteredNotes.count)
            .huiToast(
                viewModel: .init(
                    text: viewModel.listState.errorMessage,
                    style: .error
                ),
                isPresented: $viewModel.listState.isPresentedErrorToast
            )
            .onReceive(NotificationCenter.default.publisher(for: .courseDetailsForceRefreshed)) { _ in
                viewModel.reload()
            }
    }

    private var contentView: some View {
        VStack(spacing: .huiSpaces.space8) {
            if viewModel.listState.isShowfilterView {
                filterView
            }
            switch viewModel.state {
            case .data:
                dataView
            case .empty:
                NotebookEmptyView()
                    .padding(.bottom, .huiSpaces.space32)
            case .filterEmpty:
                NotebookFilterEmptyView()
                    .padding(.bottom, .huiSpaces.space32)
            }
        }
        .padding(.horizontal, .huiSpaces.space16)
        .padding(.top, .huiSpaces.space24)
    }

    private var dataView: some View {
        NotesbookCardsView(
            notes: viewModel.filteredNotes,
            selectedNote: selectedNote,
            showDeleteLoader: viewModel.listState.isDeletedNoteLoaderVisible,
            isSeeMoreButtonVisible: viewModel.listState.isSeeMoreButtonVisible,
            screenType: .course,
            focusedID: $focusedID) { selectedNote in
                viewModel.goToModuleItem(selectedNote, viewController: viewController)
                lastFocusedID = selectedNote.id
            } onTapDeleteNote: { deletedNote in
                selectedNote = deletedNote
                viewModel.deleteNote(deletedNote)
            } onTapSeeMore: {
                viewModel.seeMore()
            }
            .accessibilityHint(String(localized: "Double tap to open page", bundle: .horizon))
            .onAppear { restoreFocusIfNeeded(after: 0.1) }
    }

    private var filterView: some View {
        VStack(spacing: .zero) {
            HStack {
                listStatus
                Spacer()
                Text(viewModel.filteredNotes.count.description)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p1)
                    .accessibilityLabel(String(format: String(localized: "Count of visible notes is %@. "), viewModel.filteredNotes.count.description))
            }
        }
    }

    @ViewBuilder
    private var listStatus: some View {
        let selectedLabel = viewModel.listState.selectedLable ?? viewModel.courseLables.first
        SelectionPopover(
            items: viewModel.courseLables,
            accessibilityLabel: String(format: String(localized: "Selected label is %@. "), selectedLabel?.name ?? ""),
            selectedItem: selectedLabel,
            accessibilityHint: String(localized: "Double tab to select a different label", bundle: .horizon)
        ) { seletected in
            viewModel.listState.selectedLable = seletected
            viewModel.listState.selectedCourse = .init(id: viewModel.courseID ?? "", name: "")
            viewModel.filter()
            lastFocusedID = selectLabelFocusedID
            restoreFocusIfNeeded()
        }
        .fixedSize(horizontal: true, vertical: false)
        .id(selectLabelFocusedID)
        .accessibilityFocused($focusedID, equals: selectLabelFocusedID)
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

    private func restoreFocusIfNeeded(after: Double = 1) {
        guard let lastFocused = lastFocusedID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedID = lastFocused
        }
    }
}

#if DEBUG
#Preview {
    NotebookCourseView(
        viewModel: .init(
            pageURL: "",
            courseID: "",
            interactor: CourseNoteInteractorPreview(),
            router: AppEnvironment.shared.router
        )
    )
}
#endif
