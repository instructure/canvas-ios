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
        NotesBody(
            title: "",
            leading: {},
            trailing: {}
        ) {
            VStack(spacing: .huiSpaces.primitives.large) {
                HStack {
                    HorizonUI.IconButton(.huiIcons.arrowBack, type: .white) {
                        viewModel.onClose(viewController: viewController)
                    }
                    .hidden(viewModel.isBackButtonHidden)

                    Text(viewModel.title)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.bold22)
                        .foregroundColor(.textDarkest)

                    HorizonUI.IconButton(.huiIcons.arrowBack, type: .white) {}
                        .hidden()
                }
                .background(HorizonUI.colors.surface.pagePrimary)

                HStack(spacing: .huiSpaces.primitives.xSmall) {
                    NoteCardFilterButton(
                        type: .confusing,
                        selected: viewModel.isConfusing
                    ).onTapGesture {
                        viewModel.onToggleConfusing()
                    }
                    NoteCardFilterButton(
                        type: .important,
                        selected: viewModel.isImportant
                    ).onTapGesture {
                        viewModel.onToggleImportant()
                    }
                }

                ZStack {
                    TextField("", text: $viewModel.note, axis: .vertical)
                        .disabled(viewModel.isTextEditorDisabled)
                        .onTapGesture { viewModel.onTapTextEditor() }
                        .padding(.huiSpaces.primitives.small)
                        .frame(minHeight: 112, alignment: .topLeading)
                        .frame(maxWidth: .infinity)
                        .scrollDisabled(true)
                        .background(.white)
                        .cornerRadius(.huiSpaces.primitives.xSmall)
                        .huiElevation(level: viewModel.isTextEditorDisabled ? .level0 : .level4)

                    if viewModel.isTextEditorDisabled {
                        Color.clear.contentShape(Rectangle())
                            .onTapGesture { viewModel.onTapTextEditor() }
                    }
                }

                VStack(spacing: .huiSpaces.primitives.mediumSmall) {
                    if viewModel.isSaveVisible {
                        Button {
                            viewModel.onSave(viewController: viewController)
                        } label: {
                            Text(String(localized: "Save", bundle: .horizon))
                        }
                        .buttonStyle(
                            HorizonUI.ButtonStyles.primary(.blue, fillsWidth: true)
                        )
                        .disabled(viewModel.isSaveDisabled)
                    }

                    if viewModel.isCancelVisible {
                        Button {
                            viewModel.onCancel()
                        } label: {
                            Text(String(localized: "Cancel", bundle: .horizon))
                        }
                        .buttonStyle(.primary(.white, fillsWidth: true))
                    }
                }

                if viewModel.isActionButtonsVisible {
                    HStack {
                        HorizonUI.IconButton(.huiIcons.delete, type: .red) {
                            viewModel.onDelete()
                        }

                        HorizonUI.IconButton(.huiIcons.ai, type: .ai) { }

                        HorizonUI.IconButton(.huiIcons.edit, type: .white) {
                            viewModel.onEdit()
                        }
                    }
                }
            }
            .padding(.vertical, .huiSpaces.primitives.large)
        }
        .alert(isPresented: $viewModel.isDeleteAlertPresented) {
            Alert(
                title: Text(String(localized: "Confirmation", bundle: .horizon)),
                message: Text(String(localized: "Are you sure you want to proceed?", bundle: .horizon)),
                primaryButton: .default(Text(String(localized: "Yes", bundle: .horizon))) {
                    viewModel.onDeleteConfirmed(viewController: viewController)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    NavigationView {
        NotebookNoteView(
            viewModel: NotebookNoteViewModel(
                notebookNoteInteractor: NotebookNoteInteractor(
                    courseNotesRepository: CourseNotesRepositoryPreview.instance
                ),
                router: AppEnvironment.shared.router,
                noteId: "1",
                isEditing: false
            )
        )
    }
}
