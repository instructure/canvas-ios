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

struct EditNotebookView: View {
    // MARK: - Private variables

    @Environment(\.viewController) private var viewController
    @State private var showDeleteConfirmation = false
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - State / Dependencies

    @State var viewModel: EditNotebookViewModel

    var body: some View {
        baseScreen
            .background(Color.huiColors.surface.pageSecondary)
            .scrollDismissesKeyboard(.immediately)
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBarView }
            .huiToast(
                viewModel: .init(
                    text: viewModel.errorMessage,
                    style: .error
                ),
                isPresented: $viewModel.isErrorMessagePresented
            )
    }

    private var baseScreen: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: false,
                scrollBounce: .basedOnSize,
                loaderBackgroundColor: .huiColors.surface.pageSecondary
            )
        ) { proxy in
            VStack(alignment: .leading, spacing: .huiSpaces.space24) {
                NotebookLabelFilterButton(selectedLable: viewModel.selectedLabel) { label in
                    viewModel.selectedLabel = label
                }

                HighlightedText(
                    text: viewModel.highlightedText,
                    type: viewModel.selectedLabel
                )

                noteView(proxy: proxy)

                footerView
            }
            .padding(.vertical, .huiSpaces.space24)
            .padding(.horizontal, .huiSpaces.space16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .confirmationDialog(
                "",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .hidden
            ) {
                Button(String(localized: "Delete note"), role: .destructive) {
                    viewModel.deleteNoteAndDismiss(viewController: viewController)
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
    }

    // MARK: - Note Input

    @ViewBuilder
    private func noteView(proxy: GeometryProxy) -> some View {
        TextArea(
            text: $viewModel.note,
            placeholder: String(localized: "Add a note (optional)"),
            proxy: proxy
        )
        .focused($isTextFieldFocused)
    }

    // MARK: - Navigation Bar
    private var navigationBarView: some View {
        HStack {

            HorizonUI.PrimaryButton(
                String(localized: "Cancel"),
                type: .whiteGrayOutline,
                isSmall: true
            ) {
                viewModel.close(viewController)
            }

            Spacer()

            Text(String(localized: "Edit note"))
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.h4)

            Spacer()

            HorizonUI.PrimaryButton(
                String(localized: "Save"),
                type: .institution,
                isSmall: true
            ) {
                viewModel.update(viewController: viewController)
            }
            .disabled(!viewModel.isSaveButtonEnabled)

        }
        .padding([.horizontal, .top], .huiSpaces.space16)
        .background(Color.huiColors.surface.pageSecondary)
        .hidden(viewModel.state == .loading)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Text(viewModel.courseNote?.dateFormatted ?? "")
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.labelSmall)

            Spacer()

            HorizonUI.PrimaryButton(
                String(localized: "Delete note"),
                type: .dangerInverse,
                isSmall: true,
                leading: .huiIcons.delete
            ) {
                showDeleteConfirmation.toggle()
            }
        }
    }
}

#if DEBUG
#Preview {
    EditNotebookView(
        viewModel: .init(
            courseNotebookNote: CourseNotebookNote.example
        ) {}
    )
}
#endif
