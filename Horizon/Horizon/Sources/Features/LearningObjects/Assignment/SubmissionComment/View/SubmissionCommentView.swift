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

import Core
import HorizonUI
import SwiftUI

struct SubmissionCommentView: View {
    @Bindable var viewModel: SubmissionCommentViewModel
    @FocusState private var isTextAreaFocused: Bool
    @State private var selectedAttachment: CommentAttachment?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController

    var body: some View {
        GeometryReader { geoProxy in
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    switch viewModel.viewState {
                    case .initialLoading:
                        loadingView
                    case .data, .postingComment:
                        dataView(geoProxy: geoProxy, scrollProxy: scrollProxy)
                    case .error:
                        Text("Error loading comments.")
                    }
                }
            }
            .toolbar(.hidden)
            .padding(.horizontal, .huiSpaces.space24)
            .background(Color.huiColors.surface.pagePrimary)
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
            .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private func dataView(geoProxy: GeometryProxy, scrollProxy: ScrollViewProxy) -> some View {
        VStack(alignment: .center) {
            commentListView
            if viewModel.arePaginationButtonsVisible {
                HStack {
                    HorizonUI.IconButton(Image.huiIcons.chevronLeft, type: .gray) {
                        viewModel.goPrevious()
                    }
                    .disabled(!viewModel.isPreviousButtonEnabled)
                    .opacity(viewModel.isPreviousButtonEnabled ? 1 : 0.5)
                    Spacer()
                    HorizonUI.IconButton(Image.huiIcons.chevronRight, type: .gray) {
                        viewModel.goNext()
                    }
                    .disabled(!viewModel.isNextButtonEnabled)
                    .opacity(viewModel.isNextButtonEnabled ? 1 : 0.5)
                }
            }
            addCommentView(proxy: geoProxy)
            postButton
            Spacer()
        }
        .onChange(of: isTextAreaFocused) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    scrollProxy.scrollTo("PostButton", anchor: .bottom)
                }
            }
        }
        .onFirstAppear {
            withAnimation {
                scrollProxy.scrollTo("PostButton", anchor: .bottom)
            }
        }
    }

    private var commentListView: some View {
        ForEach(viewModel.comments) { comment in
            commentView(comment)
        }
        .padding(.top, .huiSpaces.space24)
    }

    @ViewBuilder
    private func commentView(_ comment: SubmissionComment) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            VStack(alignment: .leading, spacing: .huiSpaces.space2) {
               HStack {
                    Text(comment.authorName)
                        .huiTypography(.labelLargeBold)
                        .foregroundStyle(Color.huiColors.text.title)
                       Spacer()
                       HorizonUI.Badge(type: .solidColor, style: .primary)
                           .hidden(comment.isRead)
                }
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
            attachmentsViews(comment.attachments)
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

    private func attachmentsViews(_ attachments: [CommentAttachment]) -> some View {
        ForEach(attachments) { attachment in
            Button {
                selectedAttachment = attachment
            } label: {
                attachmentRow(for: attachment)
            }
        }
    }

    private func attachmentRow(for attachment: CommentAttachment) -> some View {
        HorizonUI.UploadedFile(
            fileName: attachment.displayName ?? "",
            actionType: selectedAttachment == attachment
            ? (viewModel.fileState == .loading ? .loading : .download)
            : .download,
            isSelected: selectedAttachment == attachment
        ) {
            handleAttachmentTap(attachment)
        }
    }

    private func handleAttachmentTap(_ attachment: CommentAttachment) {
        selectedAttachment = attachment
        if viewModel.fileState == .loading {
            viewModel.cancelDownload()
        } else {
            viewModel.downloadFile(attachment: attachment, viewController: viewController)
        }
    }

    @ViewBuilder
    private func addCommentView(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("Add Comment", bundle: .horizon)
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.title)
            TextArea(
                text: $viewModel.text,
                proxy: proxy
            )
            .focused($isTextAreaFocused)
        }
        .padding(.top, .huiSpaces.space24)
        .onTapGesture {
            isTextAreaFocused = true
        }
    }

    private var navigationBar: some View {
        ZStack {
            HStack(spacing: .zero) {
                Spacer()
                HStack(spacing: .huiSpaces.space8) {
                    HorizonUI.icons.chat
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                    Text("Comments", bundle: .horizon)
                        .huiTypography(.h3)
                        .foregroundStyle(Color.huiColors.text.title)
                }
                Spacer()
            }

            HStack(spacing: .zero) {
                Spacer()
                HorizonUI.IconButton(
                    HorizonUI.icons.close,
                    type: .white
                ) {
                    dismiss()
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space24)
        .padding(.bottom, 6)
        .background(Color.huiColors.surface.pagePrimary)
        .huiCornerRadius(level: .level5, corners: .top)
    }

    private var postButton: some View {
        SavingButton(
            title: String(localized: "Post", bundle: .horizon),
            type: .institution,
            fillsWidth: true,
            isLoading: postingCommentBinding,
            isDisabled: Binding(
                get: { viewModel.text.isEmpty },
                set: { _ in }
            )
        ) {
            viewModel.postComment()
        }
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space32)
        .id("PostButton")
    }

    private var postingCommentBinding: Binding<Bool> {
        Binding(
            get: { viewModel.viewState == .postingComment },
            set: { _ in }
        )
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            HorizonUI.Spinner(
                size: .small,
                showBackground: true
            )
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
    }
}

// TODO: Implement a proper design system component
private struct TextArea: View {
    @Binding var text: String
    let proxy: GeometryProxy

    var body: some View {
        textField
            .background(Color.huiColors.surface.cardPrimary)
            .huiBorder(
                level: .level1,
                color: .huiColors.lineAndBorders.containerStroke,
                radius: HorizonUI.CornerRadius.level1_5.attributes.radius
            )
            .huiCornerRadius(level: .level1_5)
            .huiTypography(.p1)
    }

    private var textField: some View {
        UITextViewWrapper(text: $text) {
            let tv = UITextView()
            tv.isScrollEnabled = false
            tv.textContainer.widthTracksTextView = true
            tv.textContainer.lineBreakMode = .byWordWrapping
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.font = HorizonUI.fonts.uiFont(font: HorizonUI.Typography.Name.p1.font)
            tv.widthAnchor.constraint(equalToConstant: proxy.frame(in: .global).width - (2 * 16)).isActive = true
            return tv
        }
        .foregroundStyle(text.isEmpty ? Color.huiColors.text.placeholder : Color.huiColors.text.body)
        .frame(minHeight: 120, alignment: .top)
        .padding(.huiSpaces.space8)
    }
}

#if DEBUG
#Preview {
    SubmissionCommentAssembly.makePreview()
}
#endif
