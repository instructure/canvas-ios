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

struct CreateMessageView: View {

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: CreateMessageViewModel
    private let peopleSelectionViewModel: PeopleSelectionViewModel = .init()

    var body: some View {
        VStack(alignment: .leading) {
            header
            bodyContent
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private

    private var bodyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .huiSpaces.space24) {
                peopleSelection
                individualMessageCheckbox
                messageTitleInput
                messageBodyInput
                Spacer()
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }

    private var footer: some View {
        HStack {
            Spacer()
            HorizonUI.PrimaryButton(
                String(localized: "Cancel", bundle: .horizon),
                type: .white
            ) {
                viewModel.close(viewController: viewController)
            }

            HorizonUI.PrimaryButton(
                String(localized: "Send", bundle: .horizon),
                type: .institution
            ) {
                viewModel.sendMessage(viewController: viewController)
            }
        }
        .frame(height: 92)
        .padding(.horizontal, .huiSpaces.space24)
        .overlay(
            divider,
            alignment: .top
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.huiColors.surface.divider)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private var individualMessageCheckbox: some View {
        HorizonUI.Controls.Checkbox(
            isOn: $viewModel.isIndividualMessageEnabled,
            title: String(localized: "Send individual messages to each recipient")
        )
    }

    private var header: some View {
        HStack {
            Text("Create Message")
                .huiTypography(.h2)
            Spacer()
            HorizonUI.IconButton(
                HorizonUI.icons.close,
                type: .white,
                isSmall: true
            ) {
                viewModel.close(viewController: viewController)
            }
        }
        .frame(height: 88)
        .padding(.horizontal, .huiSpaces.space24)
        .overlay(
            divider,
            alignment: .bottom
        )
    }

    private var messageBodyInput: some View {
        HorizonUI.TextArea(
            $viewModel.body,
            placeholder: String(localized: "Message", bundle: .horizon)
        )
        .frame(height: 144)
    }

    private var messageTitleInput: some View {
        HorizonUI.TextInput(
            $viewModel.title,
            placeholder: String(localized: "Title/Subject", bundle: .horizon)
        )
    }

    private var peopleSelection: some View {
        PeopleSelectionView(viewModel: peopleSelectionViewModel)
    }
}

#Preview {
    CreateMessageView(
        viewModel: .init()
    )
}
