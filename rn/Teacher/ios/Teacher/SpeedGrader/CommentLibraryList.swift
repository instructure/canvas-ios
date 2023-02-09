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
import Core

struct CommentLibraryList: View {

    @ObservedObject var viewModel: SubmissionCommentLibraryViewModel
    @Binding var comment: String
    let dismissed: () -> Void

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
                .frame(maxHeight: .infinity)
        case .empty:
            emptyView
        case .data(let comments):
            commentList(comments)
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No suggestions available", bundle: .core)
                .font(.regular17)
                .foregroundColor(.textDarkest)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }

    @ViewBuilder
    private func commentList(_ comments: [LibraryComment]) -> some View {
        List(comments) { libraryComment in
            commentView(libraryComment)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func commentView(_ libraryComment: LibraryComment) -> some View {
        Button(action: {
            select(comment: libraryComment.text)
        }, label: {
            HStack {
                commentText(libraryComment: libraryComment)
                    .font(.regular15)
                    .foregroundColor(.textDarkest)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        })
    }

    @ViewBuilder
    private func commentText(libraryComment: LibraryComment) -> some View {
        let attributes = AttributeContainer([.font: UIFont.scaledNamedFont(.bold15)])
        viewModel.attributedText(with: libraryComment.text, rangeString: $comment, attributes: attributes)
    }

    func select(comment: String) {
        self.comment = comment
        dismissed()
    }
}
