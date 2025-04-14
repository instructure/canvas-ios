//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct CommentLibrarySheet: View {

    @ObservedObject var viewModel: SubmissionCommentLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var comment: String
    let sendAction: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerView
                CommentLibraryList(viewModel: viewModel, comment: $comment) {
                    presentationMode.wrappedValue.dismiss()
                }
                CommentEditorView(
                    text: $comment,
                    shouldShowCommentLibrary: false,
                    showCommentLibrary: .constant(false),
                    action: editorAction, containerHeight: geometry.size.height
                )
                    .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .background(Color.backgroundLight).onChange(of: comment) { text in
                        viewModel.comment = text
                    }
            }.onAppear {
                viewModel.comment = comment
                viewModel.viewDidAppear()
            }
        }
    }

    @ViewBuilder
    var headerView: some View {
        ZStack {
            Text("Comment Library", bundle: .teacher).font(.semibold17).foregroundColor(.textDarkest)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                dismissView
            })
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibility(label: Text("Close", bundle: .teacher))
        }
        .padding()
        Divider()
    }

    @ViewBuilder
    var dismissView: some View {
        ZStack {
            Circle().foregroundColor(.borderMedium).frame(width: 30, height: 30).opacity(0.3)
            Image.xLine.foregroundColor(.textDarkest).frame(width: 12.5, height: 12.5)
        }
    }

    func editorAction() {
        sendAction()
        presentationMode.wrappedValue.dismiss()
    }
}
