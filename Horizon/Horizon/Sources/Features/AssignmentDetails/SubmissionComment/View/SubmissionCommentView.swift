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

import HorizonUI
import SwiftUI

struct SubmissionCommentView: View {
    let viewModel: SubmissionCommentViewModel
    @State private var text = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .center) {
                    commentListView
                    addCommentView
                    postButton
                    Spacer()
                }
                .onChange(of: text) { _, _ in
                    withAnimation {
                        proxy.scrollTo("PostButton", anchor: .bottom)
                    }
                }
            }
            .toolbar(.hidden)
            .padding([.top, .horizontal], .huiSpaces.space24)
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
            .background(Color.huiColors.surface.pagePrimary)
        }
    }

    private var commentListView: some View {
        ForEach(viewModel.comments) { comment in
            commentView(comment)
        }
    }

    @ViewBuilder
    private func commentView(_ comment: SubmissionComment) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            VStack(alignment: .leading, spacing: .huiSpaces.space2) {
                Text(comment.authorName)
                    .huiTypography(.labelLargeBold)
                    .foregroundStyle(Color.huiColors.text.title)

                if let createdAtString = comment.createdAtString {
                    Text(createdAtString)
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.timestamp)
                }
                if let attempt = comment.attemptString {
                    Text(attempt)
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.timestamp)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(comment.comment)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
        }
        .padding(.huiSpaces.space16)
        .background(Color.huiColors.surface.pageSecondary)
        .huiBorder(
            level: .level1,
            color: .huiColors.lineAndBorders.lineStroke,
            radius: HorizonUI.CornerRadius.level3.attributes.radius
        )
        .huiCornerRadius(level: .level3)
        .padding(.leading, comment.isCurrentUsersComment ? .huiSpaces.space24 : .zero)
        .padding(.trailing, comment.isCurrentUsersComment ? .zero : .huiSpaces.space24)
    }

    private var addCommentView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("Add Comment")
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.title)
            TextArea(
                text: $text,
                placeholderText: "Placeholder text"
            )
        }
        .padding(.top, .huiSpaces.space24)
    }

    private var navigationBar: some View {
        HStack(alignment: .center, spacing: .zero) {
            HorizonUI.IconButton(
                HorizonUI.icons.arrowBack,
                type: .white
            ) {
                viewModel.goBack()
            }
            Spacer()
            HStack(spacing: .huiSpaces.space8) {
                HorizonUI.icons.chat
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Comments")
                    .huiTypography(.h3)
                    .foregroundStyle(Color.huiColors.text.title)
            }
            Spacer()
            HorizonUI.IconButton(
                HorizonUI.icons.close,
                type: .white
            ) {
                dismiss()
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var postButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Post", bundle: .horizon),
            type: .blue,
            fillsWidth: true
        ) {
            print("post tapped")
        }
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space32)
        .id("PostButton")
    }
}

// TODO: Implement a proper design system component
private struct TextArea: View {
    @Binding var text: String
    let placeholderText: String

    var body: some View {
        textField
            .background(Color.huiColors.surface.cardPrimary)
            .huiBorder(
                level: .level1,
                color: .huiColors.lineAndBorders.containerStroke,
                radius: HorizonUI.CornerRadius.level1_5.attributes.radius
            )
            .huiCornerRadius(level: .level1_5)
    }

    private var textField: some View {
        TextField(text: $text, axis: .vertical) {
            if text.isEmpty {
                Text(text)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.placeholder)
            } else {
                Text(placeholderText)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
            }
        }
        .frame(minHeight: 120, alignment: .top)
        .padding(.huiSpaces.space8)
    }
}

#Preview {
    SubmissionCommentAssembly.makePreview()
}
