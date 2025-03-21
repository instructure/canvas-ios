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
        .onAppear {
            isFocused = true
            viewModel.listenToChatBot(viewController: viewController)
        }
        .paddingStyle([.horizontal, .top], .standard)
        .padding(.bottom, 23)
        .applyHorizonGradient()
    }

    private var topHeader: some View {
        ZStack(alignment: .trailingLastTextBaseline) {
            AssistTitle()

            Button {
                viewModel.dismiss(controller: viewController)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color.huiColors.icon.default)
                    .padding()
                    .background(Color.huiColors.surface.pageSecondary)
                    .clipShape(.circle)
            }
        }
    }

    private func contentView() -> some View {
        ScrollViewReader { scrollViewProxy in
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.messages) { message in
                    AssistChatMessageView(message: message)
                        .id(message.id)
                        .transition(.scaleAndFade)
                }
            }
            .onAppear {
                viewModel.scrollViewProxy = scrollViewProxy
            }
        }
    }

    private var sendMessageView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {

            Text(String(localized: "Enter a Prompt", bundle: .horizon))
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.surfaceColored)

            HStack {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 44)
                    .frame(maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .focused($isFocused)
                    .cornerRadius(HorizonUI.CornerRadius.level1.attributes.radius)
                    .overlay(
                        RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1.attributes.radius)
                            .stroke(Color.huiColors.surface.overlayWhite, lineWidth: 1)
                    )
                    .foregroundColor(Color.huiColors.text.surfaceColored)
                    .scrollContentBackground(.hidden)
                    .background(.clear)

                Button {
                    viewModel.send()
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
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        AnyTransition.opacity
            .combined(with: .modifier(
                active: ScaleEffectModifier(scale: 0.8),
                identity: ScaleEffectModifier(scale: 1.0)
            ))
    }
}

struct ScaleEffectModifier: ViewModifier {
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
    }
}

#if DEBUG
#Preview {
    AssistChatView(
        viewModel: .init(
            chatBotInteractor: AssistChatInteractorPreview(),
            router: AppEnvironment.shared.router
        )
    )
}
#endif
