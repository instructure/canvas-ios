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
        VStack(spacing: .huiSpaces.space32) {
            topHeader
            ScrollView {
                contentView()
            }
            .scrollDismissesKeyboard(.immediately)
            sendMessageView
        }
        .scrollIndicators(.hidden)
        .onReceive(viewModel.shouldOpenKeyboardPublisher) { value in
            isFocused = value
        }
        .onChange(of: viewModel.isRetryButtonVisible) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.scrollViewProxy?.scrollTo(retryViewId, anchor: .bottom)
            }
        }
        .onFirstAppear { viewModel.setViewController(viewController) }
        .padding(.huiSpaces.space24)
        .animation(.smooth, value: [viewModel.isBackButtonVisible, viewModel.isRetryButtonVisible])
        .applyHorizonGradient()
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
        .huiToast(
            viewModel: .init(text: String(localized: "Error fetching response.", bundle: .horizon), style: .error),
            isPresented: $viewModel.isErrorToastPresented
        )
    }

    private var topHeader: some View {
        HStack {
            HorizonUI.IconButton(Image.huiIcons.arrowBack, type: .white, isSmall: true) {
                viewModel.setInitialState()
            }
            .hidden(!viewModel.isBackButtonVisible)
            Spacer()
            AssistTitle()
            Spacer()
            HorizonUI.IconButton(Image.huiIcons.close, type: .white, isSmall: true) {
                viewModel.dismiss(controller: viewController)
            }
        }
    }

    private func contentView() -> some View {
        ScrollViewReader { scrollViewProxy in
            LazyVStack(alignment: .leading, spacing: .huiSpaces.space16) {
                ForEach(viewModel.messages) { message in
                    AssistChatMessageView(message: message)
                        .id(message.id)
                        .transition(.scaleAndFade)
                }
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
            .onAppear {
                viewModel.scrollViewProxy = scrollViewProxy
            }
        }
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
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {

            Text(String(localized: "Enter a Prompt", bundle: .horizon))
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.surfaceColored)

            HStack(spacing: .huiSpaces.space16) {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 44)
                    .frame(maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .huiTypography(.p1)
                    .focused($isFocused)
                    .cornerRadius(HorizonUI.CornerRadius.level1.attributes.radius)
                    .padding(.huiSpaces.space4)
                    .overlay(
                        RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level1_5.attributes.radius)
                            .inset(by: 0.6)
                            .stroke(Color.huiColors.surface.overlayWhite, lineWidth: 1.2)
                    )
                    .foregroundColor(Color.huiColors.text.surfaceColored)
                    .scrollContentBackground(.hidden)
                    .background(.clear)

                HorizonUI.IconButton(Image.huiIcons.arrowUpward, type: .white) {
                    viewModel.send()
                }
                .opacity(viewModel.isDisableSendButton ? 0.5 : 1)
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
