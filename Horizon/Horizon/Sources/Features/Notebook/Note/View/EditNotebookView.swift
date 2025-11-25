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

    // MARK: - A11y Properties

    @AccessibilityFocusState private var focusedLabelID: String?
    private let selectLabelFocusedID = "selectLabelFocusedID"

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
                NotebookLabelFilterButton(selectedLabel: viewModel.selectedLabel) { label in
                    viewModel.selectedLabel = label
                    restoreFocusIfNeeded()
                }
                .id(selectLabelFocusedID)
                .accessibilityFocused($focusedLabelID, equals: selectLabelFocusedID)

                HighlightedText(
                    text: viewModel.highlightedText,
                    type: viewModel.selectedLabel
                )
                .accessibilityLabel(
                    String.localizedStringWithFormat(
                        String(localized: "Highlighted text is %@ label type is %@", bundle: .horizon),
                        viewModel.highlightedText,
                        viewModel.selectedLabel.label
                    )
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
        .accessibilityLabel(
            String.localizedStringWithFormat(
                String(localized: "Note content is %@", bundle: .horizon),
                viewModel.note.isEmpty ? String(localized: "Empty. You can write a note.") : viewModel.note
            ))
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
            .accessibilityHint(Text(String(localized: "Double tap to dismiss the screen")))

            Spacer()

            Text(String(localized: "Edit note"))
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.h4)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            HorizonUI.PrimaryButton(
                String(localized: "Save"),
                type: .institution,
                isSmall: true
            ) {
                viewModel.update(viewController: viewController)
            }
            .disabled(!viewModel.isSaveButtonEnabled)
            .accessibilityHint(viewModel.isSaveButtonEnabled
                               ? Text(String(localized: "Save changes made to the note"))
                               : Text(String(localized: "Make any changes to the note to enable the save button"))
            )

        }
        .padding([.horizontal, .top], .huiSpaces.space16)
        .background(Color.huiColors.surface.pageSecondary)
        .hidden(viewModel.state == .loading)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if let dateFormatted = viewModel.courseNote?.dateFormatted, !dateFormatted.isEmpty {
                Text(dateFormatted)
                    .foregroundStyle(Color.huiColors.text.timestamp)
                    .huiTypography(.labelSmall)
                    .accessibilityLabel(String(localized: "Note created on \(dateFormatted)"))
            }

            Spacer()

            HorizonUI.PrimaryButton(
                String(localized: "Delete note"),
                type: .dangerInverse,
                isSmall: true,
                leading: .huiIcons.delete
            ) {
                showDeleteConfirmation.toggle()
            }
            .accessibilityAction {
                viewModel.deleteNoteAndDismiss(viewController: viewController)
            }
        }
    }

    private func restoreFocusIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            focusedLabelID = selectLabelFocusedID
        }
    }
}

#if DEBUG
#Preview {
    EditNotebookView(
        viewModel: .init(
            courseNotebookNote: CourseNotebookNote.example
        ) { _ in }
    )
}
#endif
