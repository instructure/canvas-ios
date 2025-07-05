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

import Combine
import Core
import SwiftUI

struct CommentLibraryScreen: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: CommentLibraryViewModel

    private let contextColor: Color
    private let sendAction: () -> Void

    init(
        viewModel: CommentLibraryViewModel,
        contextColor: Color,
        sendAction: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.contextColor = contextColor
        self.sendAction = sendAction
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                    .frame(maxHeight: .infinity)
            case .empty:
                emptyView
            case .data:
                commentList
            case .error:
                emptyView // not handled
            }

            CommentInputView(
                comment: viewModel.comment,
                commentLibraryButtonType: .closeLibrary,
                isAttachmentButtonEnabled: false,
                contextColor: contextColor,
                commentLibraryAction: { dismiss() },
                addAttachmentAction: { _ in },
                sendAction: {
                    sendAction()
                    dismiss()
                }
            )
        }
        .navigationBarTitleView(String(localized: "Comment Library", bundle: .teacher))
        .toolbar {
            doneButton
        }
        .navigationBarStyle(.modal)
        .background(.backgroundLightest)
    }

    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done", bundle: .teacher)
                    .font(.semibold16)
                    .foregroundStyle(contextColor)
            }
        }
    }

    private var commentList: some View {
        List {
            ForEach(viewModel.comments) { libraryComment in
                commentCell(libraryComment)
                    .listRowInsets(.zero)
                    .listRowSeparator(.hidden)
                    .listRowSpacing(0)
            }
            PagingButton(endCursor: $viewModel.endCursor) { _, finished in
                viewModel.loadNextPage(completion: finished)
            }
            .font(.regular15)
            .foregroundStyle(Brand.shared.primary.asColor)
        }
        .listStyle(.plain)
    }

    private func commentCell(_ libraryComment: LibraryComment) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                didSelectComment(libraryComment.text)
            } label: {
                commentText(libraryComment.text)
                    .font(.regular14, lineHeight: .fit)
                    .foregroundStyle(.textDarkest)
                    .multilineTextAlignment(.leading)
                    .paddingStyle(set: .standardCell)
            }

            InstUI.Divider(viewModel.comments.last == libraryComment ? .full : .padded)
        }
        .background(.backgroundLightest)
    }

    @ViewBuilder
    private func commentText(_ comment: String) -> some View {
        let attributes = AttributeContainer([.font: UIFont.scaledNamedFont(.bold14)])
        viewModel.attributedText(
            with: comment,
            rangeString: Binding(
                get: { viewModel.comment.value },
                set: { viewModel.comment.value = $0 }
            ),
            attributes: attributes
        )
    }

    private var emptyView: some View {
        Text("No suggestions available", bundle: .teacher)
            .font(.regular17)
            .foregroundStyle(.textDarkest)
            .frame(maxHeight: .infinity, alignment: .center)
    }

    private func didSelectComment(_ comment: String) {
        viewModel.comment.value = comment
        dismiss()
    }

    private func dismiss() {
        viewModel.dismiss(controller)
    }
}
