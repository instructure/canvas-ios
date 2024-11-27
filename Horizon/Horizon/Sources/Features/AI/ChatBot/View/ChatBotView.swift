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

import SwiftUI
import Core

struct ChatBotView: View {
    // MARK: - Properties

    @Bindable var viewModel: ChatBotViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.viewController) private var viewController

    var body: some View {
        VStack {
            topHeader
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(refreshable: false)
            ) { _ in
                contentView()
            }
            .scrollDismissesKeyboard(.immediately)
            Spacer()
            sendMessageView
        }
        .scrollIndicators(.hidden)
        .onAppear { isFocused = true }
        .paddingStyle([.horizontal, .top], .standard)
        .padding(.bottom, 23)
        .applyHorizonGradient()
    }

    private var topHeader: some View {
        ZStack(alignment: .trailingLastTextBaseline) {
            Text("AI Learning Assist")
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .font(.bold20)

            Button {
                viewModel.dismiss(controller: viewController)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.textLightest)
                    .padding()
                    .background(Color.backgroundLightest.opacity(0.2))
                    .clipShape(.circle)
            }
        }
    }

    private func contentView() -> some View {
        ScrollViewReader { scrollViewProxy in
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.messages) { message in
                    ChatBotMessageBubbleView(message: message)
                        .id(message.id)
                }
            }
            .onChange(of: viewModel.messages) {
                if let lastMessage = viewModel.messages.last {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private var sendMessageView: some View {
        HStack {
            TextEditor(text: $viewModel.message)
                .frame(minHeight: 50)
                .frame(maxHeight: 100)
                .fixedSize(horizontal: false, vertical: true)
                .focused($isFocused)
                .clipShape(.rect(cornerRadius: 8))

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundStyle(viewModel.isDisableSendButton ? Color.textLight : Color.backgroundSuccess)
                    .padding()
                    .background(Color.backgroundLightest)
                    .opacity(viewModel.isDisableSendButton ? 0.3 : 1)
                    .clipShape(Circle())
            }
            .disabled(viewModel.isDisableSendButton)
        }
    }
}

#if DEBUG
#Preview {
    ChatBotView(viewModel: .init(router: AppEnvironment.shared.router))
}
#endif
