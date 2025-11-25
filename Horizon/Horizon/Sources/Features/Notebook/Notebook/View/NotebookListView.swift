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

struct NotebookListView: View {
    // MARK: - A11y Properties

    @State private var lastFocusedID: String?
    @AccessibilityFocusState private var focusedID: String?
    private let selectLabelFocusedID = "selectLabelFocusedID"
    private let selectCourseFocusedID = "selectCourseFocusedID"

    // MARK: - Private Properties

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State private var selectedNote: CourseNotebookNote?

    // MARK: - Dependencies

    @State var viewModel: NotebookListViewModel

    var body: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary
                .ignoresSafeArea()

            contentView
                .overlay { loaderView }
                .toolbar(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.huiColors.surface.pageSecondary)
                .huiCornerRadius(level: .level4, corners: [.topLeft, .topRight])

                .safeAreaInset(edge: .top, spacing: .zero) {
                    if isShowHeader {
                        navigationBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.linear, value: isShowHeader)
        }
        .animation(.easeInOut, value: viewModel.listState.isNoteDeleted)
        .animation(.smooth, value: viewModel.filteredNotes.count)
        /// Set `shouldReset` to true when adding notes while `keepObserving` is enabled.
        /// This ensures the pagination resets correctly to include the new notes.
        .onDisappear { viewModel.listState.shouldReset = true }
        .huiToast(
            viewModel: .init(
                text: viewModel.listState.errorMessage,
                style: .error
            ),
            isPresented: $viewModel.listState.isPresentedErrorToast
        )
    }

    private var contentView: some View {
        VStack(spacing: .zero) {
            if viewModel.listState.isShowfilterView {
                filterView
            }
            ScrollView(showsIndicators: false) {
                navigationBarHelperView
                switch viewModel.state {
                case .data:
                    dataView
                case .empty:
                    NotebookEmptyView()
                case .filterEmpty:
                    NotebookFilterEmptyView()
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear { restoreFocusIfNeeded(after: 0.1) }
    }

    private var filterView: some View {
        VStack(spacing: .zero) {
            HStack {
                listCourses
                listStatus
                Spacer()
                Text(viewModel.filteredNotes.count.description)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .huiTypography(.p1)
                    .accessibilityLabel(String(format: String(localized: "Count of visible notes is %@. "), viewModel.filteredNotes.count.description))
            }
            .padding([.horizontal, .top], .huiSpaces.space16)
            if isShowDivider {
                Rectangle()
                    .fill(Color.huiColors.primitives.grey14)
                    .frame(height: 1.5)
                    .padding(.top, .huiSpaces.space16)
            }
        }
    }

    private var dataView: some View {
        NotesbookCardsView(
            notes: viewModel.filteredNotes,
            selectedNote: selectedNote,
            showDeleteLoader: viewModel.listState.isDeletedNoteLoaderVisible,
            isSeeMoreButtonVisible: viewModel.listState.isSeeMoreButtonVisible,
            screenType: .list,
            focusedID: $focusedID) { selectedNote in
                lastFocusedID = selectedNote.id
                viewModel.goToModuleItem(selectedNote, viewController: viewController)
            } onTapDeleteNote: { deletedNote in
                selectedNote = deletedNote
                viewModel.deleteNote(deletedNote)
            } onTapSeeMore: {
                viewModel.seeMore()
            }
            .accessibilityHint(String(localized: "Double tap to open page", bundle: .horizon))
            .accessibilityFocused($focusedID, equals: selectCourseFocusedID)
    }

    private var listCourses: some View {
        SelectionPopover(
            items: viewModel.courses,
            selectedItem: viewModel.listState.selectedCourse ?? viewModel.courses.first,
            accessibilityHint: String(localized: "Double tab to select a different course", bundle: .horizon)
        ) { seletected in
            viewModel.listState.selectedCourse = seletected
            viewModel.filter()
            lastFocusedID = selectCourseFocusedID
            restoreFocusIfNeeded()
        }
        .frame(maxWidth: 200)
        .id(selectCourseFocusedID)
        .accessibilityFocused($focusedID, equals: selectCourseFocusedID)
    }

    private var listStatus: some View {
        SelectionPopover(
            items: viewModel.courseLables,
            selectedItem: viewModel.listState.selectedLable ?? viewModel.courseLables.first,
            accessibilityHint: String(localized: "Double tab to select a different label", bundle: .horizon)
        ) { seletected in
            viewModel.listState.selectedLable = seletected
            viewModel.filter()
            lastFocusedID = selectLabelFocusedID
            restoreFocusIfNeeded()
        }
        .fixedSize(horizontal: true, vertical: false)
        .id(selectLabelFocusedID)
        .accessibilityFocused($focusedID, equals: selectLabelFocusedID)
    }

    private var navigationBarHelperView: some View {
        Color.clear
            .frame(height: 16)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
                isShowDivider = frame.minY < 100
            }
    }

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in viewModel.goBack(viewController) },
            onClose: nil
        ) {
            Text("Notebook", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(Color.huiColors.text.title)
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space8)
        .background(Color.huiColors.surface.pagePrimary)
        .accessibilityElement(children: .contain)
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
    NotebookListView(
        viewModel: .init(
            pageURL: "",
            courseID: "",
            interactor: CourseNoteInteractorPreview(),
            router: AppEnvironment.shared.router
        )
    )
}
#endif
