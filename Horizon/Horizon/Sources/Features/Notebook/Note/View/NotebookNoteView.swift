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

    var body: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space24) {
                titleBar

                highlightedText

                labels

                note

                VStack(spacing: .huiSpaces.space16) {
                    saveButton
                    cancelButton
                }

                deleteButton
            }
            .padding(.vertical, .huiSpaces.space36)
            .padding(.horizontal, .huiSpaces.space24)
        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.huiColors.surface.pagePrimary, for: .navigationBar)
        .background(Color.huiColors.surface.pagePrimary)
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
    }

    @ViewBuilder
    private var cancelButton: some View {
        if viewModel.isCancelVisible {
            Button {
                viewModel.cancelEditingAndReset()
            } label: {
                Text(String(localized: "Cancel", bundle: .horizon))
            }
            .buttonStyle(.primary(.white, fillsWidth: true))
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        if viewModel.isDeleteButtonVisible {
            HorizonUI.IconButton(.huiIcons.delete, type: .red) {
                viewModel.presentDeleteAlert()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var highlightedText: some View {
        NotebookSectionHeading(title: String(localized: "Highlight", bundle: .horizon))

        if viewModel.isHighlightedTextVisible {
            Text(viewModel.highlightedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.regular14Italic)
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
    }

    @ViewBuilder
    private var note: some View {
        NotebookSectionHeading(title: String(localized: "Add a Note (Optional)", bundle: .horizon))

        ZStack {
            TextField("", text: $viewModel.note, axis: .vertical)
                .disabled(viewModel.isTextEditorDisabled)
                .onTapGesture { viewModel.edit() }
                .padding(.huiSpaces.space12)
                .frame(minHeight: 120, alignment: .topLeading)
                .frame(maxWidth: .infinity)
                .scrollDisabled(true)
                .background(.white)
                .cornerRadius(.huiSpaces.space12)
                .huiElevation(level: viewModel.isTextEditorDisabled ? .level0 : .level4)

            if viewModel.isTextEditorDisabled {
                Color.clear.contentShape(Rectangle())
                    .onTapGesture { viewModel.edit() }
            }
        }
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
                HorizonUI.ButtonStyles.primary(.blue, fillsWidth: true)
            )
            .disabled(viewModel.isSaveDisabled)
        }
    }

    private var titleBar: some View {
        HStack {
            HorizonUI.IconButton(.huiIcons.arrowBack, type: .white) {}
                .hidden()

            HStack {
                HorizonUI.icons.menuBookNotebook
                Text("Notebook", bundle: .horizon)
                    .huiTypography(.h3)
            }
            .frame(maxWidth: .infinity)

            HorizonUI.IconButton(.huiIcons.close, type: .white) {
                viewModel.close(viewController: viewController)
            }
            .opacity(viewModel.closeButtonOpacity)
        }
        .background(HorizonUI.colors.surface.pagePrimary)
    }
}

#Preview {
    NavigationView {
        NotebookNoteView(
            viewModel: NotebookNoteViewModel(
                courseNoteInteractor: CourseNoteInteractorPreview(),
                router: AppEnvironment.shared.router,
                noteId: "1",
                isEditing: false
            )
        )
    }
}
