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

struct HorizonMessageDetailsView: View {
    @ObservedObject var model: HorizonMessageDetailsViewModel
    @Environment(\.viewController) private var viewController

    init(model: HorizonMessageDetailsViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(alignment: .leading) {
            titleBar
                .padding(.horizontal, HorizonUI.spaces.space24)
            messages
            replyArea
        }
        .background(HorizonUI.colors.surface.pagePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }

    private var messages: some View {
        InstUI.BaseScreen(
            state: .data,
            config: .init(refreshable: true),
            refreshAction: model.refresh
        ) { _ in
            VStack(spacing: HorizonUI.spaces.space24) {
                ForEach(model.messages, id: \.id) { message in
                    messageBody(message)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(
                                    model.messages.firstIndex(where: {$0.id == message.id}) == 0 ?
                                        .clear :
                                        HorizonUI.colors.lineAndBorders.lineStroke
                                ),
                            alignment: .top
                        )
                }
            }
            .padding(.top, HorizonUI.spaces.space16)
            .padding(.bottom, HorizonUI.spaces.space24)
            .padding(.leading, HorizonUI.spaces.space24)
            .padding(.trailing, HorizonUI.spaces.space24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(HorizonUI.colors.surface.pageSecondary)
        .clipShape(
            .rect(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
    }

    private func messageBody(_ message: MessageViewModel) -> some View {
        VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
            HStack {
                Text(message.author)
                    .huiTypography(.labelLargeBold)
                Spacer()
                Text(message.date)
                    .huiTypography(.p3)
                    .foregroundStyle(HorizonUI.colors.text.timestamp)
            }
            Text(message.body)
                .huiTypography(.p1)
        }
        .padding(.vertical, HorizonUI.spaces.space16)
    }

    private var replyArea: some View {
        VStack(spacing: HorizonUI.spaces.space16) {
            HorizonUI.TextArea(
                $model.reply,
                placeholder: String(localized: "Reply", bundle: .horizon),
                autoExpand: true
            )
            HStack {
                Spacer()
                ZStack {
                    HorizonUI.Spinner(size: .xSmall)
                        .opacity(model.loadingSpinnerOpacity)
                    sendButton
                        .opacity(model.sendButtonOpacity)
                }
            }
        }
        .background(HorizonUI.colors.surface.pagePrimary)
        .padding(.horizontal, HorizonUI.spaces.space24)
        .padding(.vertical, HorizonUI.spaces.space16)
    }

    private var sendButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Send", bundle: .horizon),
            type: .institution
        ) {
            model.sendMessage(viewController: viewController)
        }
        .disabled(model.isSendDisabled)
    }

    private var titleBar: some View {
        HStack {
            backButton
            Spacer()
            Text(model.title)
                .huiTypography(.labelLargeBold)
                .foregroundColor(HorizonUI.colors.surface.institution)
            Spacer()
            backButton
                .opacity(0)
        }
        .frame(maxWidth: .infinity)
    }

    private var backButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.arrowBack,
            type: .ghost
        ) {
            model.pop(viewController: viewController)
        }
    }
}

#Preview {
    HorizonMessageDetailsView(
        model: HorizonMessageDetailsViewModel(
            router: AppEnvironment.shared.router,
            messageDetailsInteractor: MessageDetailsInteractorPreview(
                env: AppEnvironment.shared,
                subject: "Test Subject",
                messages: []
            ),
            composeMessageInteractor: ComposeMessageInteractorPreview(),
            allowArchive: false
        )
    )
}
