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
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Comment Library", bundle: .core).font(.bold24).foregroundColor(.textDarkest)
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image.xLine.foregroundColor(.textDark)
                    })
                }.padding()
                Divider()
                CommentList(comment: $comment, comments: viewModel.comments) {
                    presentationMode.wrappedValue.dismiss()
                }
                CommentEditor(text: $comment, action: editorAction, containerHeight: geometry.size.height)
                    .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .background(Color.backgroundLight)
            }.onAppear {
                viewModel.viewDidAppear()
            }
        }
    }

    struct CommentList: View {

        @Binding var comment: String
        let comments: [LibraryComment]
        let dismissed: () -> Void

        var body: some View {

            let filteredComments = comments.filter { comment.isEmpty || $0.text.lowercased().contains(comment.lowercased()) }
            if filteredComments.isEmpty {
                VStack() {
                    Spacer()
                    Text("No suggestions available", bundle: .core)
                        .font(.regular17)
                        .foregroundColor(.textDarkest)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            } else {
                List(filteredComments , id: \.id) { libraryComment in
                    Button(action: {
                        select(comment: libraryComment.text)
                    }, label: {
                        HStack {
                            if #available(iOS 15, *) {
                                //let attributedString = boldAttributed(text: libraryComment.text, query: comment)
                                Text(libraryComment.text) {
                                    if let range = $0.range(of: comment, options: .caseInsensitive) {
                                        $0[range].font = .bold17
                                    }
                                }.font(.regular17)
                                    .foregroundColor(.textDarkest)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text(libraryComment.text)
                                    .font(.regular17)
                                    .foregroundColor(.textDarkest)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                    })
                }.listStyle(.plain).animation(.default)
            }
        }

        func select(comment: String) {
            self.comment = comment
            dismissed()
        }
    }

    func editorAction() {
        sendAction()
        presentationMode.wrappedValue.dismiss()
    }
}


struct CommentLibrarySheet_Previews: PreviewProvider {

    static var previews: some View {
        CommentLibrarySheet(viewModel: SubmissionCommentLibraryViewModel(), comment: .constant("comment")) { }
    }
}
