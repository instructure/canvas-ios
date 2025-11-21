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
                viewModel.realod()
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
            showCourseName: false) { selectedNote in
                viewModel.goToModuleItem(selectedNote, viewController: viewController)
            } onTapDeleteNote: { deletedNote in
                selectedNote = deletedNote
                viewModel.deleteNote(deletedNote)
            } onTapSeeMore: {
                viewModel.seeMore()
            }
    }

    private var filterView: some View {
        VStack(spacing: .zero) {
            HStack {
                listStatus
                Spacer()
                Text(viewModel.filteredNotes.count.description)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p1)
            }
        }
    }

    private var listStatus: some View {
        SelectionPopover(
            items: viewModel.courseLables,
            selectedItem: viewModel.listState.selectedLable ?? viewModel.courseLables.first
        ) { seletected in
            viewModel.listState.selectedLable = seletected
            viewModel.listState.selectedCourse = .init(id: viewModel.courseID ?? "", name: "")
            viewModel.filter()
        }
        .fixedSize(horizontal: true, vertical: false)
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
