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

import HorizonUI
import SwiftUI
import Core

struct AssistChatView: View {
    // MARK: - Properties

    @Bindable var viewModel: AssistChatViewModel
    @FocusState private var isFocused: Bool
    private let retryViewId = "retry"
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack(spacing: .zero) {
            topHeader
            VStack(spacing: .zero) {
                ScrollView {
                    contentView
                }
                .scrollDismissesKeyboard(.immediately)
                sendMessageView
            }
            .scrollIndicators(.hidden)
            .onReceive(viewModel.shouldOpenKeyboardPublisher) { value in
                isFocused = value
            }
            .onFirstAppear { viewModel.viewController = viewController }
            .padding(.horizontal, .huiSpaces.space16)
            .animation(.smooth, value: [viewModel.isBackButtonVisible, viewModel.isRetryButtonVisible])
            .overlay {
                if viewModel.isLoaderVisible {
                    HorizonUI.Spinner(size: .small, foregroundColor: Color.huiColors.surface.cardPrimary)
                }
            }
            .huiToast(
                viewModel: .init(text: String(localized: "Error fetching response.", bundle: .horizon), style: .error),
                isPresented: $viewModel.isErrorToastPresented
            )
        }
        .applyHorizonGradient()
    }

    private var topHeader: some View {
        HTitleBar(
            page: .assist,
            actionStates: [.back: viewModel.isBackButtonVisible ? .enabled : .hidden]
        ) { action in
            if action == .back {
                viewModel.dismiss(controller: viewController)
            } else {
                viewModel.setInitialState()
            }
        }
    }

    private var contentView: some View {
        ScrollViewReader { scrollViewProxy in
            LazyVStack(alignment: .leading, spacing: .huiSpaces.space16) {
                ForEach(viewModel.messages, id: \.id) { message in
                    AssistChatMessageView(message: message)
                        .id(message.id)
                }
                .animation(.smooth, value: viewModel.isRetryButtonVisible)
                .animation(.smooth, value: viewModel.messages)
                if viewModel.isRetryButtonVisible {
                    Button {
                        viewModel.retry()
                    } label: {
                        retryView
                    }
                    .frame(minHeight: 44)
                    .padding(.top, -(.huiSpaces.space16))
                    .id(retryViewId)
                }
            }
            .animation(.smooth, value: viewModel.messages)
            .onReceive(viewModel.showMoreButtonPublisher) { id in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation {
                        scrollViewProxy.scrollTo(id, anchor: .top)
                    }
                }
            }
        }
        .padding(.vertical, .huiSpaces.space16)
    }

    private var retryView: some View {
        HStack(spacing: .zero) {
            Text("This prompt was not received. Try again", bundle: .horizon)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(Color.huiColors.text.surfaceColored)
                .huiTypography(.labelSmall)
            Image.huiIcons.refresh
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.huiColors.icon.surfaceColored)
        }
    }

    private var sendMessageView: some View {
        VStack(alignment: .leading) {
            textInputMessageView
            HStack(spacing: .zero) {
                Spacer()
                textInputSendButton
            }
            .overlay(
                Rectangle()
                    .fill(Color.huiColors.surface.divider)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .background(
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level2.attributes.radius)
                .fill(Color.huiColors.surface.cardPrimary)
        )
    }

    private var textInputMessageView: some View {
        TextEditor(text: $viewModel.message)
            .overlay(
                ZStack {
                    Text("Ask a question")
                        .foregroundColor(Color.huiColors.text.placeholder)
                        .padding(.top, .huiSpaces.space8)
                        .opacity(viewModel.message.isEmpty && !isFocused ? 1 : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            )
            .frame(minHeight: 36)
            .frame(maxHeight: 100)
            .fixedSize(horizontal: false, vertical: true)
            .huiTypography(.p1)
            .focused($isFocused)
            .padding(.horizontal, .huiSpaces.space12)
            .padding(.top, .huiSpaces.space12)
            .foregroundColor(Color.huiColors.text.timestamp)
            .scrollContentBackground(.hidden)
    }

    private var textInputSendButton: some View {
        HorizonUI.IconButton(Image.huiIcons.sendFilled, type: .black) {
            viewModel.send()
        }
        .padding(.huiSpaces.space12)
        .disabled(viewModel.isDisableSendButton)
    }
}

#if DEBUG
#Preview {
    AssistChatView(
        viewModel: .init(
            assistChatInteractor: AssistChatInteractorPreview(),
            router: AppEnvironment.shared.router
        )
    )
}
#endif
