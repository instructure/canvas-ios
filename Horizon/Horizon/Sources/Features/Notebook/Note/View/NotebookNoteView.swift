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

struct NotebookNoteView: View {
    @State var viewModel: NotebookNoteViewModel
    @Environment(\.viewController) private var viewController
    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            baseScreen
            HorizonUI.Toast(
                viewModel: .init(
                    text: String(localized: "Your note has been saved", bundle: .horizon),
                    style: .success,
                    isShowCancelButton: false
                )
            )
            .padding(.top, .huiSpaces.space32)
            .opacity(viewModel.isSavedToastVisible ? 1 : 0)
            .animation(.easeInOut, value: viewModel.isSavedToastVisible)
        }
        .frame(maxHeight: .infinity)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var baseScreen: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: false,
                loaderBackgroundColor: .huiColors.surface.pagePrimary
            )
        ) { _ in
            VStack(spacing: 0) {
                titleBar
                highlightedText
                labels
                note
                ZStack {
                    saveButton
                    deleteButton
                }
                .padding(.top, .huiSpaces.space16)
            }
            .padding(.vertical, .huiSpaces.space36)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.huiColors.surface.pagePrimary, for: .navigationBar)
            .alert(isPresented: $viewModel.isDeleteAlertPresented) {
                Alert(
                    title: Text(String(localized: "Confirmation", bundle: .horizon)),
                    message: Text(String(localized: "Are you sure you want to proceed?", bundle: .horizon)),
                    primaryButton: .default(Text(String(localized: "Yes", bundle: .horizon))) {
                        viewModel.deleteNoteAndDismiss(viewController: viewController)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onTapGesture {
                if isTextFieldFocused {
                    isTextFieldFocused = false
                }
            }
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        if viewModel.isDeleteButtonVisible {
            HorizonUI.IconButton(.huiIcons.delete, type: .danger, isSmall: true) {
                viewModel.presentDeleteAlert()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var highlightedText: some View {
        NotebookSectionHeading(title: String(localized: "Highlight", bundle: .horizon))

        if viewModel.isHighlightedTextVisible {
            HighlightedText(viewModel.highlightedText, ofTypes: viewModel.courseNoteLabels)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.p1)
                .padding(.top, .huiSpaces.space12)
        }
    }

    @ViewBuilder
    private var labels: some View {
        NotebookSectionHeading(title: String(localized: "Label", bundle: .horizon))

        HStack(spacing: .huiSpaces.space8) {
            NoteCardFilterButton(
                type: .confusing,
                selected: viewModel.isConfusing
            ).onTapGesture {
                viewModel.toggleConfusing()
            }
            NoteCardFilterButton(
                type: .important,
                selected: viewModel.isImportant
            ).onTapGesture {
                viewModel.toggleImportant()
            }
        }
        .padding(.top, .huiSpaces.space12)
    }

    @ViewBuilder
    private var note: some View {
        NotebookSectionHeading(title: String(localized: "Add a Note (Optional)", bundle: .horizon))

        ZStack {
            UITextViewWrapper(text: $viewModel.note) {
                let tv = UITextView()
                tv.translatesAutoresizingMaskIntoConstraints = false
                tv.isScrollEnabled = false
                tv.textContainer.widthTracksTextView = true
                tv.textContainer.lineBreakMode = .byWordWrapping
                tv.font = HorizonUI.fonts.uiFont(font: HorizonUI.Typography.Name.p1.font)
                tv.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - (.huiSpaces.space24 * 2))
                    .isActive = true
                tv.backgroundColor = HorizonUI.colors.surface.cardSecondary.uiColor
                return tv
            }
            .frame(minHeight: 120)
            .onTapGesture { viewModel.edit() }
            .cornerRadius(.huiSpaces.space12)
            .background(
                RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                    .stroke(HorizonUI.colors.lineAndBorders.containerStroke, lineWidth: 1)
            )
            .focused($isTextFieldFocused)

            if viewModel.isTextEditorEditable == false {
                Color.clear.contentShape(Rectangle())
                    .onTapGesture { viewModel.edit() }
            }
        }
        .padding(.top, .huiSpaces.space12)
    }

    @ViewBuilder
    private var saveButton: some View {
        if viewModel.isSaveVisible {
            Button {
                viewModel.saveAndDismiss(viewController: viewController)
            } label: {
                Text(String(localized: "Save", bundle: .horizon))
            }
            .buttonStyle(
                HorizonUI.ButtonStyles.primary(.institution, fillsWidth: true)
            )
            .disabled(viewModel.isSaveDisabled)
        }
    }

    private var titleBar: some View {
        TitleBar(
            onClose: viewModel.closeButtonDisabled ? nil : viewModel.close
        ) {
            NotebookTitle()
        }
    }
}

#if DEBUG
#Preview {
    NotebookNoteView(
        viewModel: .init(
            courseNotebookNote: CourseNotebookNote.example
        )
    )
}
#endif
